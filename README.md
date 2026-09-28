# PS4 Linux - Arch KDE on a jailbroken PS4

A short, tested guide for running Linux (Arch Linux with KDE Plasma) on a jailbroken PS4 from a USB drive.

Everything here follows the exact setup that worked on my console. If your setup is different, read the notes first.

> [!WARNING]
> Use at your own risk. Writing the USB image erases the whole USB drive. Nothing here touches the PS4 internal drive except two files copied to `/data/linux/boot/`.

## Tested consoles

| # | Console | Southbridge | Firmware | Kernel | Result |
|---|---|---|---|---|---|
| 1 | PS4 Pro CUH-7116B (7100 series) | Belize | 13.52 (GoldHEN) | 7.1.7 Strawberry General (Aeolia/Belize) | Works |

More consoles will be added as they are tested.

## Tested setup (console #1)

| Item | Value |
|---|---|
| Console | PS4 Pro CUH-7116B (7100 series, Belize southbridge) |
| Firmware | 13.52, jailbroken with GoldHEN |
| Kernel | 7.1.7 "Strawberry" General FullLTO (Aeolia/Belize) by rmuxnet |
| Initramfs | DionKill better-initramfs, "External HDD" variant |
| Payload | `linux-1024mb.elf` (1GB VRAM) from ps4-linux-loader |
| Distro | Arch KDE v1.1.1 by Erkkola |
| USB | 12GB raw image, MBR, p1 FAT32 (boot), p2 ext4 label `psxitarch` (root) |

### Other PS4 models

The kernel in `boot/` is the Aeolia/Belize build. Southbridge matters more than the model name: PS4 Slim (CUH-2xxx) and PS4 Pro (CUH-7xxx) consoles ship with either a **Belize** or a **Baikal** southbridge, and they need different kernels. Baikal consoles need rmuxnet's separate Baikal kernel (7.0.8), which is not tested here yet.

Do **not** use kernel 6.15.4 on the tested Pro: it gave a blue light and no HDMI signal.

## Files in this repo

| File | What it is |
|---|---|
| `boot/bzImage` | Kernel 7.1.7 Strawberry General FullLTO (Aeolia/Belize), unmodified from the official release |
| `boot/kernel-7.1.7-Strawberry-General.config` | The kernel config from the same release |
| `boot/initramfs.cpio.gz` | DionKill better-initramfs, "External HDD" variant, unmodified |
| `payload/linux-1024mb.elf` | Linux loader payload, 1GB VRAM (ps4-linux-loader v25.1) |
| `tools/build-img.sh` | Builds the 12GB USB image (Linux or WSL, run as root) |
| `tools/write-img.ps1` | Writes the image raw to a USB drive on Windows |

SHA-256:

```
072113898347932c34888cfdc7556953ee27233c0727cc45f419a57119242480  boot/bzImage
3f373bd6c469e490eaf4e5cf4d2e8ed77cf7bb91449b6a18da6a6529d479169b  boot/initramfs.cpio.gz
623c3b68592437b612ede22a4fc1a6f1eef6b17c4b16a1270100ece04cb3c98f  payload/linux-1024mb.elf
```

The distro is **not** included (about 2GB). Download it from the official release (see step 1).

## What you need

- A PS4 with a Belize southbridge (tested: PS4 Pro CUH-7116B), jailbroken with GoldHEN (FTP server on port 2121 and BinLoader enabled)
- A USB drive of 16GB or more (USB 3.0 recommended), plugged into the PS4 USB port
- A Windows PC with WSL (Ubuntu), or any Linux PC
- An FTP client (for example FileZilla or WinSCP)
- A DualShock 4 controller, plus a USB keyboard and mouse for the first setup

## Installation

### 1. Download the distro

1. Open the Arch KDE v1.1.1 release: https://github.com/ErkkolaMaitohappo/arch-ps4-aur-smth-fork/releases/tag/v1.1.1%2Bkde
2. Download `psxitarch.tar.xz` (about 2GB).
3. Optional - check the hash. It must be:

```
501709552cb4e4781c2ad9fbc3099c3277a4cdc9dbabd4693791692acc4ccd13
```

On Windows:

```powershell
Get-FileHash .\psxitarch.tar.xz -Algorithm SHA256
```

### 2. Build the USB image

Windows cannot pass a removable USB drive into WSL, so first build the image as a file, then write it raw in step 3.

1. Open WSL (Ubuntu) and go to the folder of this repo.
2. Run (change the paths to yours):

```bash
sudo bash tools/build-img.sh /mnt/d/ps4/psxitarch.tar.xz boot/bzImage boot/initramfs.cpio.gz /mnt/d/ps4/psxitarch-usb.img
```

3. Wait for `BUILD_IMG_OK`. You now have a 12GB `psxitarch-usb.img`:
   - Partition 1: 512MB FAT32 with `bzImage` and `initramfs.cpio.gz`
   - Partition 2: ext4 with label `psxitarch`, containing Arch KDE

### 3. Write the image to the USB drive

1. Plug the USB drive into the PC.
2. Open PowerShell **as Administrator** and find the disk number of the USB drive:

```powershell
Get-Disk
```

3. Write the image (change the path and the disk number):

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\write-img.ps1 -ImagePath D:\ps4\psxitarch-usb.img -DiskNumber 1
```

4. The script shows the disk details and refuses to write to non-USB, boot or system disks. Type the disk number again to confirm.
5. Wait for `WRITE_DONE_OK`. Windows may ask to format the drive - click **Cancel**.

### 4. Copy the kernel and initramfs to the PS4

1. Jailbreak the PS4 and make sure GoldHEN is running.
2. Connect with your FTP client to the PS4 IP address, port `2121`.
3. Create the folder `/data/linux/boot/` if it does not exist.
4. Upload `boot/bzImage` and `boot/initramfs.cpio.gz` into `/data/linux/boot/`.

The same two files are already on the first partition of the USB drive. Having them in both places is the setup that worked.

### 5. Boot Linux

1. Plug the USB drive into the PS4.
2. Send `payload/linux-1024mb.elf` with the GoldHEN BinLoader. From a PC on the same network, for example:

```powershell
# Windows PowerShell - replace the IP with your PS4 IP
$c = New-Object Net.Sockets.TcpClient('192.168.1.50', 9020)
$s = $c.GetStream(); $b = [IO.File]::ReadAllBytes("$PWD\payload\linux-1024mb.elf")
$s.Write($b, 0, $b.Length); $s.Close(); $c.Close()
```

```bash
# Linux / WSL
nc -q 1 192.168.1.50 9020 < payload/linux-1024mb.elf
```

> Port `9020` is the port that worked on my console. GoldHEN's own README lists its BinLoader on port `9090`, so try that if `9020` does not answer.

3. The screen goes black and the PS4 boots into Linux. The initramfs waits about 10 seconds and then mounts the `psxitarch` partition by itself.
4. Log in with user `abc`, password `abc`.

Notes:

- The first boot may hang on a **white light**. Turn the console off, jailbreak again and send the payload again - the retry works.
- The 1GB payload (`linux-1024mb.elf`) is the one I used and recommend (tested on the Pro).
- If you land in the rescue shell instead of the desktop, type:

```
exec start-psxitarch.sh
```

### 6. Expand the root partition

The image is only 12GB. To use the whole USB drive, open a terminal (Konsole) in Linux:

1. Check the disk names (on my console the USB was `sdb` and the root partition `sdb2`):

```bash
lsblk
```

2. Expand the partition and the file system:

```bash
sudo parted /dev/sdb resizepart 2 100%
sudo resize2fs /dev/sdb2
```

If `parted` asks for confirmation, answer `Yes`.

> If pasting commands adds junk characters, type them by hand.

## After installation

### DualShock 4 controller

- **USB**: plug it in, it works right away.
- **Bluetooth**: pair it in System Settings - Bluetooth (hold Share + PS until the light bar flashes). You need to pair it again on every boot.

### Network

- **Ethernet**: works with no setup.
- **Wi-Fi** (still in testing):
  - Prefer a 2.4GHz network.
  - If you have more than one keyboard layout, type the Wi-Fi password in the English layout.
  - If it gets stuck on "Configuring interface", run (replace `SSID` with your network name):

```bash
sudo nmcli con modify "SSID" wifi.cloned-mac-address permanent wifi.powersave 2
```

  Then reconnect.

### Rebooting and getting back into Linux

- Rebooting from Linux returns you to the normal PS4 system.
- To get back into Linux:
  1. Jailbreak the PS4 (GoldHEN).
  2. Plug in the USB drive.
  3. Send `linux-1024mb.elf` again (step 5).

## Licenses and sources

- **Kernel** (`boot/bzImage`): Linux is licensed under GPL-2.0. This is an unmodified binary from rmuxnet's official release. Source code: https://gitlab.com/rmuxnet/linux (branch `zaebiz/7.1.7-Stable`, release `Release-7.1.7-Aeolia-Belize`: https://gitlab.com/rmuxnet/linux/-/releases/Release-7.1.7-Aeolia-Belize). The kernel config is included in `boot/`.
- **Initramfs** (`boot/initramfs.cpio.gz`): unmodified, from DionKill's PS4 Linux Tutorial repo (MIT): https://github.com/DionKill/ps4-linux-tutorial. It is based on better-initramfs (https://bitbucket.org/piotrkarbowski/better-initramfs) and contains BusyBox (GPL-2.0).
- **Payload** (`payload/linux-1024mb.elf`): unmodified, from ps4-linux-loader v25.1: https://github.com/ps4-linux/ps4-linux-loader/releases/tag/v25.1. Source is in the same repo; the kexec part (ps4-kexec) is BSD-licensed, by shuffle2 and marcan.
- **Distro**: not included, download it from Erkkola's release (step 1).

All binaries belong to their authors. If an author asks, I will remove a file and link to the original instead.

## Credits

- **rmuxnet** - Strawberry kernel 7.1.7 for Aeolia/Belize: https://gitlab.com/rmuxnet/linux
- **DionKill** - better-initramfs ("External HDD" variant) and the PS4 Linux Tutorial: https://github.com/DionKill/ps4-linux-tutorial
- **Erkkola (ErkkolaMaitohappo)** - Arch KDE v1.1.1 image: https://github.com/ErkkolaMaitohappo/arch-ps4-aur-smth-fork
- **ArabPixel and the ps4-linux team** - ps4-linux-loader, `linux-1024mb.elf` payload: https://github.com/ps4-linux/ps4-linux-loader
- **GoldHEN - SiSTR0** - homebrew enabler, FTP server and BinLoader: https://github.com/GoldHEN/GoldHEN
