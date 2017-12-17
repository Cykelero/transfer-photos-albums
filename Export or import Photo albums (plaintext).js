function packRootFoldersByName(folderNames, progressCallback) {
	return folderNames.map(folderName => {
		const folder = photosApp.folders.byName(folderName);
		return packFolder(folder, progressCallback);
	});
}

function unpackRootFolders(packedFolders, progressCallback) {
	return packedFolders.reduce((accumulatedMissingItems, packedFolder) => {
		return accumulatedMissingItems.concat(unpackFolder(packedFolder));
	}, []);
}


function packFolder(folder, progressCallback) {
	return {
		type: 'folder',
		name: folder.name(),
		children: toProperArray(folder.containers)
			.map(child => {
				return isAlbum(child) ? packAlbum(child, progressCallback) : packFolder(child, progressCallback);
			})
	};
}

function unpackFolder(packedFolder, destinationFolder, progressCallback) {
	let unpackedFolder;
	let missingItems = [];

	const atRoot = !destinationFolder;
	const initialFolderName = atRoot ? `${packedFolder.name} (0%)` : packedFolder.name;
	
	// Count folders, prepare progress reporting
	if (atRoot) {
		function countSubthings(packedThing) {
			if (packedThing.type !== 'folder') return 1;
			return packedThing.children.reduce((accumulatedCount, child) => {
				return accumulatedCount + countSubthings(child);
			}, 1);
		}
		
		const totalThings = countSubthings(packedFolder);
		
		let restoredThingCount = 0;
		progressCallback = function() {
			restoredThingCount++;
			progressPercentage = Math.round(restoredThingCount / totalThings * 100);
			unpackedFolder.name = `${packedFolder.name} (${progressPercentage}%)`;
		};
	}

	// Create folder
	if (atRoot) {
		photosApp.make({new: 'folder', named: initialFolderName});
	} else {
		photosApp.make({new: 'folder', named: initialFolderName, at: destinationFolder});
	}
	const ephemeralUnpackedFolder = (destinationFolder || photosApp).folders.byName(initialFolderName);
	unpackedFolder = photosApp.folders.byId(ephemeralUnpackedFolder.id());
	
	// Add children
	packedFolder.children.slice(0).reverse()
		.forEach(child => {
			switch (child.type) {
				case 'folder':
					missingItems = missingItems.concat(unpackFolder(child, unpackedFolder, progressCallback));
					break;
				case 'album':
					missingItems = missingItems.concat(unpackAlbum(child, unpackedFolder));
					progressCallback();
					break;
			}
		});
	
	progressCallback();
	
	// Finalize folder name
	if (atRoot) {
		unpackedFolder.name = packedFolder.name;
	}
	
	return missingItems;
}

function packAlbum(album, progressCallback) {
	return {
		type: 'album',
		name: album.name(),
		children: toProperArray(album.mediaItems)
			.map(child => {
				progressCallback();
				return child.id();
			})
	};
}

function unpackAlbum(packedAlbum, destinationFolder) {
	let unpackedAlbum;
	
	// Create album
	if (destinationFolder) {
		photosApp.make({new: 'album', named: packedAlbum.name, at: destinationFolder});
		unpackedAlbum = destinationFolder.albums.byName(packedAlbum.name);
	} else {
		photosApp.make({new: 'album', named: packedAlbum.name});
		unpackedAlbum = photosApp.albums.byName(packedAlbum.name);
	}
	
	// Add items
	const processedItems = packedAlbum.children.map(itemId => {
		const item = photosApp.mediaItems.byId(itemId);
		
		try {
			item.id();
			return item;
		} catch (e) {
			return itemId;
		}
	});
	
	const childItems = processedItems.filter(item => (typeof item) !== 'string');
	const missingItems = processedItems.filter(item => (typeof item) === 'string');
	
	photosApp.add(childItems, {to: unpackedAlbum});
	
	return missingItems;
}

function whileReportingProgress(initialProgressText , callback) {
	photosApp.make({new: 'album', named: initialProgressText});
	const ephemeralProgressAlbum = photosApp.albums.byName(initialProgressText);
	const progressAlbum = photosApp.albums.byId(ephemeralProgressAlbum.id());
	
	callback(progressText => {
		progressAlbum.name = progressText;
	});
	
	photosApp.delete(progressAlbum);
}

function toProperArray(automationArray) {
	let result = [];
	
	for (let i = 0; i < automationArray.length; i++) {
		result.push(automationArray[i]);
	}
	
	return result;
}

function isAlbum(value) {
	try {
		value.mediaItems();
		return true;
	} catch(e) {
		return false;
	}
}

function log(value) {
	const stringifiedValue = JSON.stringify(value);
	scriptApp.displayAlert(stringifiedValue === undefined ? 'undefined' : stringifiedValue);
}

// Run
const photosApp = Application('Photos');
const scriptApp = Application.currentApplication();
scriptApp.includeStandardAdditions = true;

const toPackNames = ['Collections'];

// // Read album structure
let packedFolders;
whileReportingProgress('Reading…', reportProgress => {
	let packedPhotoCount = 0;
	packedFolders = packRootFoldersByName(toPackNames, () => {
		packedPhotoCount++;
		if (packedPhotoCount % 111 === 0) {
			reportProgress(`Reading… (${packedPhotoCount} found)`);
		}
	});
});

// // Prompt to switch libraries
scriptApp.displayAlert('Folders successfully scanned. Now, please open the target library, then click OK to start importing.');

// // Unpack folders
const missingItems = unpackRootFolders(packedFolders);

// // Report missing items
if (missingItems.length === 0) {
	scriptApp.displayAlert('Folders successfully restored!');
} else {
	const missingItemsString = (missingItems.length === 1) ?
		'1 item is' :
		`${missingItems.length} items are`;
	
	const missingItemsText = `Folders restored. ${missingItemsString} missing. To display them, please open the source library again, then click Show.`;
	
	const dialogResult = scriptApp.displayDialog(missingItemsText, {
		buttons: ["Done", "Show"],
		defaultButton: "Show",
		cancelButton: "Done"
	});
	
	if (dialogResult.buttonReturned === 'Show') {
		const missingItemsAlbum = {
			type: 'album',
			name: '❓ Missing items',
			children: missingItems
		};
		
		unpackAlbum(missingItemsAlbum);
	}
}
