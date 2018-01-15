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
	try {
		return {
			type: 'folder',
			name: folder.name(),
			children: toProperArray(folder.containers)
				.map(child => {
					return isAlbum(child) ? packAlbum(child, progressCallback) :	 packFolder(child, progressCallback);
				})
		};
	} catch (error) {
		throw Error(`Can't find specified folder.`);
	}
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
	progressCallback(album.mediaItems.length);
	return {
		type: 'album',
		name: album.name(),
		children: toProperArray(album.mediaItems.id())
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
	
	try {
		callback(progressText => {
			progressAlbum.name = progressText;
		});
	} catch (error) {
		throw error;
	} finally {	
		photosApp.delete(progressAlbum);
	}
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

// // Ask for source name
let toPackNames = [];
const nameDialogResult = scriptApp.displayDialog('Enter the name of the folder to scan.', {
	defaultAnswer: '',
	buttons: ['Cancel', 'Scan folder'],
	defaultButton: 'Scan folder',
	cancelButton: 'Cancel'
});

if (nameDialogResult.buttonReturned === 'Scan folder') {
	toPackNames.push(nameDialogResult.textReturned);
}

// // Announce task
/*
const pluralizedFolders = toPackNames.length === 1 ? 'folder is' : 'folders are';
const formattedFolderList = toPackNames.reduce((accumulatedList, name, nameIndex, allNames) => {
	const quotedName = `“${name}”`;
	const separator = (nameIndex < allNames.length - 1) ? ', ' : ' and ';
	return (nameIndex === 0) ? quotedName : `${accumulatedList}${separator}${quotedName}`;
}, '');
scriptApp.displayAlert(`Your photo library will now be scanned for photos.\nThe specified ${pluralizedFolders} ${formattedFolderList}.`);
*/


// // Do
if (toPackNames.length > 0) {
	// Read album structure	
	let packedFolders;
	whileReportingProgress('Reading…', reportProgress => {
		let packedPhotoCount = 0;
		packedFolders = packRootFoldersByName(toPackNames, newlyPackedItemCount => {
			packedPhotoCount += newlyPackedItemCount;
			reportProgress(`Reading… (${packedPhotoCount} found)`);
		});
	});

	// Prompt to switch libraries
	const phase2DialogResult = scriptApp.displayDialog('Folders successfully scanned. Now, please open the target library, then click OK to start importing.', {
		buttons: ["Cancel", "Import"],
		defaultButton: "Import",
		cancelButton: "Cancel"
	});
	
	if (phase2DialogResult.buttonReturned === 'Import') {
		// Unpack folders
		const missingItems = unpackRootFolders(packedFolders);
	
		// Report missing items
		if (missingItems.length === 0) {
			scriptApp.displayAlert('Folders successfully restored!');
		} else {
			const missingItemsString = (missingItems.length === 1) ?
				'1 item is' :
				`${missingItems.length} items are`;
		
			const missingItemsText = `Folders restored.\n${missingItemsString} missing. To display	 the missing items, please open the source library again, then click Show.`;
		
			const missingItemsDialogResult = scriptApp.displayDialog(missingItemsText, {
				buttons: ["Done", "Show"],
				defaultButton: "Show",
				cancelButton: "Done"
			});
		
			if (missingItemsDialogResult.buttonReturned === 'Show') {
				const missingItemsAlbum = {
					type: 'album',
					name: '❓ Missing items',
					children: missingItems
				};
			
				unpackAlbum(missingItemsAlbum);
			}
		}
	}
}
