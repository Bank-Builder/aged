#!/bin/bash
mkdir -p /home/$USER/.local/share/qed
cp qed-install.sh /home/$USER/.local/share/qed/.
cp qed-remove.sh /home/$USER/.local/share/qed/.
cp qed.sh /home/$USER/.local/share/qed/.
cp qed.conf /home/$USER/.local/share/qed/.
cp README.md /home/$USER/.local/share/qed/.

ln /home/$USER/.local/share/qed/qed.sh /home/$USER/.local/bin/qed 
ln /home/$USER/.local/share/qed/qed-remove.sh /home/$USER/.local/bin/qed-remove
chmod +x /home/$USER/.local/share/qed/qed.sh
echo "QED installed"