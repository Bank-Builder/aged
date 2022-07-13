#!/bin/bash
mkdir -p /home/$USER/.local/share/qed
cp . /home/$USER/.local/share/qed
ln /home/$USER/.local/bin/qed /home/$USER/.local/share/qed/qed.sh
ln /home/$USER/.local/bin/qed-remove /home/$USER/.local/share/qed/qed-remove.sh
chmod +x /home/$USER/.local/share/qed/qed.sh
echo "QED $(cat ver) installed"