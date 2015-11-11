When you unzip the files, they will automatically unzip into the following file structure unless you specify differently:
c:\ODSExamples\SASCode
c:\ODSExamples\Audio
c:\ODSExamples\Images
c:\ODSExamples\Videos

Some of these SAS programs included in this zip file reference files that are included in other directories in this zip file. You will need to change the file path within the SAS program to pick up the image, audio, and video files depending on how you set up your file structure. 

For example:
94m2ODSLayoutAbsoluteEx1.sas references the following images:
c:\ODSExamples\Images\orionstarHeader.jpg 
c:\ODSExamples\Images\starLarge.gif 

94m2ODSPowerPointEx2.sas references the following image:
c:\ODSExamples\Images\foldedblends.bmp

94m3epub3Example7RWIVideoCat.sas references "poster.jpg". You will need to change the sas program to pick up  "poster.jpg" from the \ODSExamples\Images directory that was created when you unzipped the files.



