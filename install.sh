#! /bin/bash
#stript to simplify installation
#Assumes that we run on a Debian-like system, using 'apt' to install things
#Default ocr language is set in CoverUP.py to Slovak (slk). It can be changed by setting the COVERUP_OCR_LANG environment variable

env_dir=coverup_venv
pdfanon=/usr/local/bin/pdfanon

sudo apt install python3-venv -y
sudo apt install tk python3-tk -y
sudo apt install tesseract-ocr -y
languages="slk ces deu fra"
for lang in $languages; do sudo apt install tesseract-ocr-$lang -y; done

rm -rf $env_dir 
sudo rm -f $pdfanon

#Create virtual environment
#/usr/bin/python3 -m venv coverup_venv
/usr/bin/python3 -m venv $env_dir

source $env_dir/bin/activate

pip install -r requirements.txt

# Create the pdfanon script in /usr/local/bin
echo "#!/bin/bash

if [ ! -n \"\$1\" ]
then
  echo \"Usage: \$0 file.pdf\"
  exit \$E_BADARGS
fi
pdf=\$1

# go to the file's directory to set the save path correctly
dir=\`dirname \$pdf\`
(
cd \$dir

app_path=$PWD
source \$app_path/$env_dir/bin/activate
\$app_path/CoverUP.py \$pdf
)
" | sudo tee $pdfanon > /dev/null

sudo chmod 755 $pdfanon

#Install the desktop file
#test functionality: gtk-launch pdfanon 4619198.pdf
sudo cp pdfanon.desktop /usr/share/applications

#Install the icon
sudo cp pdfanon.svg /usr/share/icons/hicolor/scalable/apps/

sudo update-desktop-database
sudo gtk-update-icon-cache /usr/share/icons/hicolor/

echo
echo "$pdfanon has been installed"

