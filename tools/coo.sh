if [ ! -e android_patches ]; then
  tar xzf android_patches.tgz
fi
cd android_patches
aa=$(find . -name *.patch | sort)
for a in $aa;do bb=$(grep From: $a);echo $a:${bb##From:}; done > ../list.txt
