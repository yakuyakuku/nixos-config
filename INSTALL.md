# How to Install This NixOS Config on a New Machine (e.g., Laptop)

This guide assumes you are booting from a standard NixOS Installer USB.

## 1. Prepare the Laptop
1.  **Boot** into the NixOS installer.
2.  **Connect to Wi-Fi/Internet**:
    ```bash
    sudo systemctl start wpa_supplicant
    nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"
    ```
3.  **Partition & Format Disks** (Standard NixOS procedure):
    *   Create partitions (e.g., Boot, Swap, Root).
    *   Format them (EXT4, BTRFS, etc.).
    *   Mount your root partition to `/mnt`.
    *   Mount your boot partition to `/mnt/boot`.

## 2. Generate Hardware Config
Generate the configuration specifically for your laptop's hardware (This is critical for disk UUIDs and drivers):
```bash
sudo nixos-generate-config --root /mnt
```
This creates `/mnt/etc/nixos/hardware-configuration.nix`.

## 3. Clone This Repository
1.  Enter the config directory:
    ```bash
    cd /mnt/etc/nixos
    ```
2.  **Remove default generated config**:
    ```bash
    rm configuration.nix
    ```
3.  **Clone your repo** (Replace URL with your actual repo URL):
    ```bash
    nix-shell -p git --run "git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git ."
    ```

## 4. Apply Hardware Config
Overwrite the repo's hardware config with the one you just generated for the laptop:
```bash
cp hardware-configuration.nix hardware-configuration.nix.api-bak
# The generate-config command put the file in /mnt/etc/nixos/hardware-configuration.nix
# Since we are IN that folder, it might have overwritten the repo one or sits beside it.
# Ensure the new generated file is the one being used.
```
*Note: Since you are cloning into `/mnt/etc/nixos`, the `nixos-generate-config` output should be right there. Just creating the clone might conflict with existing files, so it's safer to clone into a temp folder then copy, OR just copy the content.*

**Safer Way:**
```bash
# After generating config in /mnt/etc/nixos/
cd /mnt/etc/nixos
git init
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git fetch
git checkout -f main  # Force checkout to overwrite, BUT keep hardware-configuration.nix?
# NO, git checkout -f will overwrite local changes.
```

**Easiest Way:**
1. Clone repo to `/mnt/etc/nixos` (assuming directory is empty or you force it).
2. Run `nixos-generate-config --root /mnt`. It will overwrite `hardware-configuration.nix` with the correct laptop version.

## 5. Install
Run the install command using your flake hostname ("Delta"):
```bash
nixos-install --flake .#Delta
```

## 6. Reboot
```bash
reboot
```
Login with user `yaku`!
