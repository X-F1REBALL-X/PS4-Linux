<p align="center"><img src="images/banner.jpg" alt="PS4 Linux banner" width="100%"></p>

# PS4 Linux - Arch KDE on a jailbroken PS4

A short, tested guide for running Linux (Arch Linux with KDE Plasma) on a jailbroken PS4 from a USB drive.

Everything here follows the exact setup that worked on my console. If your setup is different, read the notes first.

> [!WARNING]
> Use at your own risk. Writing the USB image erases the whole USB drive. Nothing here touches the PS4 internal drive except two files copied to `/data/linux/boot/`.

## Tested consoles

| Model | Type | Southbridge | Kernel file | Tested FW | Status |
|---|---|---|---|---|---|
| CUH-7116B | Pro | Belize | `boot/belize/bzImage` (7.1.7) | 13.52 (GoldHEN) | Works |
| CUH-2116A | Slim | Baikal | `boot/baikal/bzImage` (7.0.8) | 13.52 (GoldHEN) | Works (KDE desktop) |

Both consoles use the same `linux-1024mb.elf` payload, the same `initramfs.cpio.gz` and the same USB drive. More consoles will be added as they are tested.

### Model series and southbridge - reference (not tested by me)

This list is from public sources, not from my own testing. Where a series says "Belize or Baikal", the motherboard decides it and the model number alone cannot tell you.

| Model series | Type | Southbridge | Kernel file |
|---|---|---|---|
| CUH-10xx | Fat | Aeolia | `boot/belize/bzImage` (Aeolia/Belize build) |
| CUH-11xx | Fat | Aeolia | `boot/belize/bzImage` (Aeolia/Belize build) |
| CUH-12xx | Fat | Belize | `boot/belize/bzImage` |
| CUH-20xx | Slim | Belize or Baikal (board SAD-001/SAD-003: Belize, SAD-002: Baikal) | depends on board |
| CUH-21xx | Slim | Belize or Baikal (board SAE-001/SAE-003: Belize 2, SAE-002/SAE-004: Baikal) | depends on board |
| CUH-22xx | Slim | Belize or Baikal (board SAF-003/SAF-005: Belize 2, SAF-004/SAF-006: Baikal) | depends on board |
| CUH-70xx | Pro | Belize | `boot/belize/bzImage` |
| CUH-71xx | Pro | Belize or Baikal (board NVB-003: Belize 2, NVB-004: Baikal) | depends on board |
| CUH-72xx | Pro | Belize or Baikal (board NVG-001/NVG-003: Belize 2, NVG-002/NVG-004: Baikal) | depends on board |

Sources: rmuxnet's Strawberry kernel console compatibility table (CUH-10xx/11xx Aeolia, CUH-12xx Belize, CUH-70xx Belize only, CUH-2xxx and CUH-7xxx Belize or Baikal), the [PS4 Linux Tutorial by DionKill](https://dionkill.github.io/ps4-linux-tutorial/revisions.html) (Aeolia only on early Fat models, Belize on late Fat, Slim and Pro, Baikal late and least supported) and the [psdevwiki Southbridge page](https://www.psdevwiki.com/ps4/Southbridge) (board numbers). The 7.1.7 kernel is built for "Aeolia / Belize"; Aeolia is not tested here.

### Supported firmware

- **ps4-linux-loader** (the `linux-1024mb.elf` payload): documented for **FW 5.05 - 13.52**. Its README marks 13.02/13.04, 13.50 and 13.52 with "(?)" (less confirmed). 13.52 works on both consoles above.
- The PS4 Linux Tutorial currently lists its payload host for **FW 5.05 - 13.02**.
- You need a working jailbreak with GoldHEN (FTP + BinLoader) on your firmware first. The jailbreak itself is not covered here.

## Tested setup

| Item | Value |
|---|---|
| Consoles | PS4 Pro CUH-7116B (Belize) and PS4 Slim CUH-2116A (Baikal) |
| Firmware | 13.52, jailbroken with GoldHEN |
| Kernel (Belize) | 7.1.7 "Strawberry" General FullLTO (Aeolia/Belize) by rmuxnet |
| Kernel (Baikal) | 7.0.8 "Strawberry" FullLTO Baikal (rmuxnet's Baikal port, mirror build) |
| Initramfs | DionKill better-initramfs, "External HDD" variant |
| Payload | `linux-1024mb.elf` (1GB VRAM) from ps4-linux-loader - the same file for both consoles |
| Distro | Arch KDE v1.1.1 by Erkkola |
| USB | 12GB raw image, MBR, p1 FAT32 (boot), p2 ext4 label `psxitarch` (root) - the same USB for both consoles |

## Which kernel do I need

The kernel depends on the **southbridge** chip inside your console, not on the model name:

| Southbridge | Kernel file |
|---|---|
| Belize (also Aeolia) | `boot/belize/bzImage` (7.1.7) |
| Baikal | `boot/baikal/bzImage` (7.0.8) |

- The model number alone does not decide it. PS4 Slim (CUH-2xxx) and PS4 Pro (CUH-7xxx) consoles were built with either a Belize or a Baikal board. Example: the CUH-7116B here is Belize, the CUH-2116A here is Baikal.
- What decides it is the motherboard (for example on the Slim 2100 series: SAE-001 / SAE-003 are Belize 2, SAE-002 / SAE-004 are Baikal) or the southbridge chip itself. See the [psdevwiki Southbridge page](https://www.psdevwiki.com/ps4/Southbridge).
- No need to open the console - you can also just try: if the Belize kernel gets stuck on a **white light** every time, try the Baikal kernel.
- Whichever kernel you pick, put it on the console as **`/data/linux/boot/bzImage`** (rename it to exactly `bzImage`).

Do **not** use kernel 6.15.4 on the tested Pro: it gave a blue light and no HDMI signal.

> [!IMPORTANT]
> **The loader prefers a `bzImage` on the USB over `/data/linux/boot/`.**
> ps4-linux-loader looks for `bzImage` (and `initramfs.cpio.gz`) in this order: `/mnt/usb0/`, `/mnt/usb1/`, `/data/linux/boot/`, `/user/system/boot/`, and uses the first one it finds.
> Recommended: do **not** put a file named `bzImage` on the USB's first partition. Keep only `initramfs.cpio.gz` there (a spare kernel is fine if it has another name, e.g. `bzImage.belize`). Then one USB works on several consoles, and each console boots its own kernel from `/data/linux/boot/bzImage`.

## Files in this repo

| File | What it is |
|---|---|
| `boot/belize/bzImage` | Kernel 7.1.7 Strawberry General FullLTO (Aeolia/Belize), unmodified from the official release |
| `boot/belize/kernel-7.1.7-Strawberry-General.config` | The kernel config from the same release |
| `boot/baikal/bzImage` | Kernel 7.0.8 Strawberry FullLTO Baikal, unmodified from the mirror linked by the PS4 Linux Tutorial |
| `boot/initramfs.cpio.gz` | DionKill better-initramfs, "External HDD" variant, unmodified - shared by both kernels |
| `payload/linux-*mb.elf` | Linux loader payloads, 32MB to 4096MB VRAM (ps4-linux-loader v25.1) - work on Belize and Baikal, see [Payloads](#payloads) |
| `images/banner.jpg` | Banner image |
| `tools/build-img.sh` | Builds the 12GB USB image (Linux or WSL, run as root) |
| `tools/write-img.ps1` | Writes the image raw to a USB drive on Windows |

SHA-256:

```
072113898347932c34888cfdc7556953ee27233c0727cc45f419a57119242480  boot/belize/bzImage
46c835f762e7b0b5400ea762b8daa1bcec638a1b769c7ec0905137bc565b1ba8  boot/baikal/bzImage
3f373bd6c469e490eaf4e5cf4d2e8ed77cf7bb91449b6a18da6a6529d479169b  boot/initramfs.cpio.gz
cb393c938898f0e1e381d673b7eb4251c87f5176d45da3b4a97719bc2f6f2d9f  payload/linux-32mb.elf
e655932de5c864bc77f620ac2ffaabfa7e3bbc6d3e9e4ae6cad7561b0a03eb0e  payload/linux-64mb.elf
ba415598d9235b91ba9dde8871dbd49d0bee889ceb07646d9002106a70c241ea  payload/linux-128mb.elf
bef32f64b560e7541f094dd89c8d012256368ec6d89c880df2547ef2a306a4f6  payload/linux-256mb.elf
7aff2eb1edb111d1e2db846b26c734ffeab4db343998d99f05e4be7d43c8b94d  payload/linux-512mb.elf
623c3b68592437b612ede22a4fc1a6f1eef6b17c4b16a1270100ece04cb3c98f  payload/linux-1024mb.elf
efb9bb027543a829b5f14d5f122a91fddbf8e04488e754607862421c36563a8a  payload/linux-2048mb.elf
e759edf99461f3eec62d3d7aef7fc2e511d736becfa66534340a133e8f2101ea  payload/linux-3072mb.elf
0d03cf3f5460985759a2eec29df0b4ae7b1c7e5450c04df99738e911e035a8db  payload/linux-4096mb.elf
```

## Payloads

All payloads are the same loader, only the VRAM size differs. VRAM is taken from system RAM (the PS4 has 8GB shared), so more VRAM means less RAM for Linux.

| File | VRAM | Use case |
|---|---|---|
| `linux-32mb.elf` | 32MB | Headless / server only |
| `linux-64mb.elf` | 64MB | Headless / server only |
| `linux-128mb.elf` | 128MB | Headless / server only |
| `linux-256mb.elf` | 256MB | Headless / server only |
| `linux-512mb.elf` | 512MB | Headless / server only |
| `linux-1024mb.elf` | 1GB | **Recommended for KDE.** Tested on the Pro and the Slim. Use it for the first boot. |
| `linux-2048mb.elf` | 2GB | More graphics memory for games and desktop effects |
| `linux-3072mb.elf` | 3GB | Even more graphics memory (not tested here) |
| `linux-4096mb.elf` | 4GB | Tested working on the Pro (FW 13.52). For heavy games or emulators. Leaves only about 4GB system RAM. |

Notes:

- A `vram.txt` file (a number in MB, for example `2048`) on the USB or in `/data/linux/boot/` overrides the payload size (per the ps4-linux-loader README). Delete it if you want the payload size to be used.
- Sizes below 1GB are meant for headless servers. The loader README says not to use them for gaming or a heavy desktop, and the PS4 Linux Tutorial notes 32MB and 64MB can cause display issues.

The distro is **not** included (about 2GB). Download it from the official release (see step 1).

## What you need

- A PS4 with a Belize or Baikal southbridge (see [Which kernel do I need](#which-kernel-do-i-need)), jailbroken with GoldHEN (FTP server on port 2121 and BinLoader enabled)
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
sudo bash tools/build-img.sh /mnt/d/ps4/psxitarch.tar.xz boot/initramfs.cpio.gz /mnt/d/ps4/psxitarch-usb.img
```

3. Wait for `BUILD_IMG_OK`. You now have a 12GB `psxitarch-usb.img`:
   - Partition 1: 512MB FAT32 with `initramfs.cpio.gz` only (no `bzImage` - see the note above)
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
2. Connect with your FTP client to the PS4 IP address, port `2121`. Use **binary** transfer mode.
3. Create the folder `/data/linux/boot/` if it does not exist.
4. Upload the kernel for your southbridge and rename it to `bzImage`:
   - Belize: `boot/belize/bzImage` -> `/data/linux/boot/bzImage`
   - Baikal: `boot/baikal/bzImage` -> `/data/linux/boot/bzImage`
5. Upload `boot/initramfs.cpio.gz` to `/data/linux/boot/initramfs.cpio.gz`.
6. Check that the file sizes on the PS4 match the files in this repo.

Tip: you can keep the other kernel next to it as a backup under another name (for example `bzImage.belize-7.1.7`). The loader only loads the file named exactly `bzImage`.

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

3. The screen goes black and the PS4 boots into Linux (the loader detects Belize or Baikal by itself, so the payload is the same). The initramfs waits about 10 seconds and then mounts the `psxitarch` partition by itself.
4. Log in with user `abc`, password `abc`.

Notes:

- The first boot may hang on a **white light**. Turn the console off, jailbreak again and send the payload again - on the Pro the retry worked.
- If it hangs on a white light **every time**, you probably have the wrong kernel for your southbridge. Try the other one (see [Which kernel do I need](#which-kernel-do-i-need)), and make sure there is no `bzImage` on the USB overriding it.
- The 1GB payload (`linux-1024mb.elf`) is the one I used and recommend (tested on the Pro).
- If you land in the rescue shell instead of the desktop, type:

```
exec start-psxitarch.sh
```

### 6. Expand the root partition

The image is only 12GB. To use the whole USB drive, open a terminal (Konsole) in Linux:

1. Check the disk names (on the Pro the USB was `sdb` and the root partition `sdb2`; check yours):

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

## Troubleshooting

- **Linux does not start after the jailbreak (black screen or white light):** this is normal and happens often. Do a full power off (hold the power button), wait a few seconds, jailbreak again and retry. The 2nd or 3rd try usually works.
- **Best routine:** plug the USB in before powering on the console. Send the ELF right after the jailbreak, without opening any games or apps first. On a black screen, wait 1-2 minutes before giving up.
- **Rescue shell with `mounting LABEL=psxitarch failed`:** the USB was not connected or not detected. Plug it in and reboot the console (resume-boot does not help).
- **Sleep / suspend is not supported:** disable it in KDE System Settings - Power Management, or run:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## Licenses and sources

- **Kernels**: Linux is licensed under GPL-2.0. Both kernels are unmodified binaries.
  - `boot/belize/bzImage`: from rmuxnet's official release `Release-7.1.7-Aeolia-Belize` (https://gitlab.com/rmuxnet/linux/-/releases/Release-7.1.7-Aeolia-Belize), branch `zaebiz/7.1.7-Stable`. The kernel config is included in `boot/belize/`.
  - `boot/baikal/bzImage`: from the mirror linked by the PS4 Linux Tutorial (https://gatto.fae5.de/archive/kernels/strawberry/baikal/7.0.8/bzImage), described there as "a mirror of the FullLTO version for baikal". Version string: `7.0.8-Strawberry-FullLTO-Baikal-+ (pask@pask-MacBookPro16-1)`, so it was built by "pask", not by rmuxnet's CI. Source: rmuxnet's Strawberry tree, branch `baikal/7.0.8-Stable`.
  - Source code for both: https://gitlab.com/rmuxnet/linux
- **Initramfs** (`boot/initramfs.cpio.gz`): unmodified, from DionKill's PS4 Linux Tutorial repo (MIT): https://github.com/DionKill/ps4-linux-tutorial. It is based on better-initramfs (https://bitbucket.org/piotrkarbowski/better-initramfs) and contains BusyBox (GPL-2.0).
- **Payload** (`payload/linux-1024mb.elf`): unmodified, from ps4-linux-loader v25.1: https://github.com/ps4-linux/ps4-linux-loader/releases/tag/v25.1. Source is in the same repo; the kexec part (ps4-kexec) is BSD-licensed, by shuffle2 and marcan.
- **Distro**: not included, download it from Erkkola's release (step 1).

All binaries belong to their authors. If an author asks, I will remove a file and link to the original instead.

## Credits

- **rmuxnet** - Strawberry kernels: 7.1.7 for Aeolia/Belize and the 7.0.8 Baikal port: https://gitlab.com/rmuxnet/linux
- **pask** - the 7.0.8 Baikal FullLTO build used here, mirrored at https://gatto.fae5.de/archive/kernels/strawberry/baikal/7.0.8/ (mirror link added to the PS4 Linux Tutorial by GattoDev-debug)
- **DionKill** - better-initramfs ("External HDD" variant) and the PS4 Linux Tutorial: https://github.com/DionKill/ps4-linux-tutorial
- **Erkkola (ErkkolaMaitohappo)** - Arch KDE v1.1.1 image: https://github.com/ErkkolaMaitohappo/arch-ps4-aur-smth-fork
- **ArabPixel and the ps4-linux team** - ps4-linux-loader, `linux-1024mb.elf` payload: https://github.com/ps4-linux/ps4-linux-loader
- **GoldHEN - SiSTR0** - homebrew enabler, FTP server and BinLoader: https://github.com/GoldHEN/GoldHEN
