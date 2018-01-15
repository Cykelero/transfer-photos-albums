# Transfer Photos albums

This script allows you to copy albums from one Photos.app photo library to another, as long as the two are related. It's been tested on macOS 10.13 High Sierra only.

## Limitations

- You can only copy between two libraries which are related, i.e. started out as a copy of the other. This means the script is mainly useful for restoring albums from a backup of the target library.
- Smart albums are not copied. You'll have to recreate them manually, sorry!

## Usage

Download the `.scpt` file; to run it, just open it (Script Editor.app will launch) and click the Run button at the top of the window.

You'll need to first open the source library, then later on, when prompted, switch to the target library.  
To open a specific photo library, launch Photos.app while holding down the Option key. If you want to open a library from a Time Machine backup, you need to first copy it somewhere else.

The script copies one whole folder (and all its subfolders and albums) at a time. If you just want to copy a single album, please enclose it in a folder 😅.

## Some details

I made this script because a few dozens of my Photos albums suddenly disappeared. Apple support couldn't help, so I needed to recover the lost albums from my own backups.

The script works by recreating the folder structure in memory: it looks at the names of the different albums and folders, and for each album, captures the IDs of the photos it contains.  
Once the scan is complete and the target library is open, the script recreates the folder structure based on the snapshot it took, by creating new albums and folders, and inserting photos, finding them by ID.
