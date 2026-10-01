# PS4 Linux

Run Linux (Arch Linux with KDE Plasma) on a jailbroken PS4 from a USB drive. Tested setup, ready-to-use files.

## Screenshot

<p align="center"><img src="images/desktop.jpg" alt="KDE Plasma desktop running on PS4" width="100%"></p>

## Tested consoles

| Model | Type | Southbridge | Kernel | Tested FW | Status |
|---|---|---|---|---|---|
| CUH-7116B | Pro | Belize | `bzImage-belize-7.1.7` | 13.52 (GoldHEN) | Works |
| CUH-2116A | Slim | Baikal | `bzImage-baikal-7.0.8` | 13.52 (GoldHEN) | Works |

Both use the same payload (`linux-1024mb.elf`), initramfs and USB drive. The loader supports FW 5.05-13.52. More consoles will be added.

## Which kernel do I need

| Southbridge | Kernel |
|---|---|
| Belize (Slim / Pro) | `bzImage-belize-7.1.7` |
| Aeolia (Fat) - untested | `bzImage-belize-7.1.7` |
| Baikal (Slim / Pro) | `bzImage-baikal-7.0.8` |

- The model number alone does not decide it: Slim (CUH-2xxx) and Pro (CUH-7xxx) can be Belize or Baikal, depending on the motherboard. Fat CUH-10xx/11xx are Aeolia, CUH-12xx and Pro CUH-70xx are Belize.
- Aeolia (PS4 Fat) should use the Belize kernel but is untested. Some Fat models have Wi-Fi/Bluetooth chips that may not work.
- Power LED check: **blue** means Linux is running on the console. If the light stays **white** for more than about 30 seconds, Linux did not boot — try the other kernel (Belize ↔ Baikal).
- On the console, the kernel must always be named `/data/linux/boot/bzImage`.
- Do not put a file named `bzImage` on the USB. The loader prefers a USB kernel over `/data/linux/boot/`, so leave it off and one USB works on every console.

## Download

Get all files from [Releases](https://gitlab.com/X-F1REBALL-X/PS4-Linux/-/releases/permalink/latest):

- `bzImage-belize-7.1.7`, `bzImage-baikal-7.0.8` - kernels
- `initramfs.cpio.gz` - initramfs (shared)
- `linux-*mb.elf` - payloads
- `psxitarch-usb.img.xz.part1`, `psxitarch-usb.img.xz.part2` - ready-made Arch Linux KDE USB image (customized), xz-compressed and split in 2 parts. *Not attached to the current release yet - use **Build it yourself** below in the meantime.*
- `build-img.sh`, `write-img.ps1` - USB image tools
- `SHA256SUMS` - checksums

**Check a download:** compare its hash with the one in `SHA256SUMS`. They must match exactly.

- Windows (PowerShell): `Get-FileHash .\linux-1024mb.elf`
- Linux: `sha256sum -c SHA256SUMS --ignore-missing`

## Payloads

| File | VRAM | Use |
|---|---|---|
| `linux-32mb.elf` to `linux-512mb.elf` | 32-512MB | Headless / server only |
| `linux-1024mb.elf` | 1GB | **Recommended for KDE.** Tested on Pro and Slim |
| `linux-2048mb.elf` | 2GB | More graphics memory |
| `linux-3072mb.elf` | 3GB | Not tested |
| `linux-4096mb.elf` | 4GB | Tested on Pro (FW 13.52). Heavy games / emulators. Leaves about 4GB RAM |

## Installation

### 1. Prepare the USB drive (16GB or more)

- **Ready-made image:** download `psxitarch-usb.img.xz.part1` and `psxitarch-usb.img.xz.part2` from [Releases](https://gitlab.com/X-F1REBALL-X/PS4-Linux/-/releases/permalink/latest). It is an Arch Linux KDE USB image (customized) that logs in straight to the KDE desktop. It fits any USB drive of 16GB or more (8.9GB uncompressed). USB 3.0 is recommended for speed. Join the two parts into one file, `psxitarch-usb.img.xz`.

On Windows:

```powershell
cmd /c copy /b psxitarch-usb.img.xz.part1 + psxitarch-usb.img.xz.part2 psxitarch-usb.img.xz
```

On Linux: `cat psxitarch-usb.img.xz.part1 psxitarch-usb.img.xz.part2 > psxitarch-usb.img.xz`

Then go to step 2.

- **Build it yourself:** get Erkkola's Arch KDE v1.1.1 rootfs `psxitarch.tar.xz`, then in WSL or Linux:

```bash
sudo bash build-img.sh psxitarch.tar.xz initramfs.cpio.gz psxitarch-usb.img
```

This creates a 12GB image: p1 FAT32 with `initramfs.cpio.gz`, p2 ext4 labeled `psxitarch` with Arch KDE.

### 2. Write the image to the USB

Writing the image erases everything on the USB drive.

**Windows:** in PowerShell as Administrator, find the USB disk number with `Get-Disk`, then:

```powershell
powershell -ExecutionPolicy Bypass -File .\write-img.ps1 -ImagePath .\psxitarch-usb.img.xz -DiskNumber 1
```

`write-img.ps1` writes the compressed `psxitarch-usb.img.xz` directly (7-Zip must be installed) or a plain `.img` (for example one you built yourself). Alternatively, write `psxitarch-usb.img.xz` directly with balenaEtcher, or extract the `.img` with 7-Zip and write it with Rufus (DD mode).

The script refuses non-USB or system disks and asks you to confirm. If Windows offers to format the drive, click Cancel.

**Linux:** find the USB with `lsblk` (replace `sdX` below), then:

```bash
xz -dc psxitarch-usb.img.xz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

After writing, the Linux partition is only as big as the image (about 8GB). To use the whole drive, expand it as described in step 5.

### 3. Copy the kernel and initramfs to the PS4

1. Jailbreak the PS4 with GoldHEN.
2. Connect with FTP to the PS4 IP, port `2121` (binary mode).
3. Create `/data/linux/boot/`.
4. Upload the kernel for your southbridge as `/data/linux/boot/bzImage`.
5. Upload `initramfs.cpio.gz` to `/data/linux/boot/`.

### 4. Boot Linux

1. Plug the USB into the PS4.
2. Jailbreak and start **GoldHEN**. Enable **BinLoader / PayLoader** on port **9090**.
3. Send `linux-1024mb.elf` (or another size from [Releases](https://gitlab.com/X-F1REBALL-X/PS4-Linux/-/releases/permalink/latest)) to that listener.

**Easiest from the PS4 browser:** open [ArabPixel WebKitty](http://webkitty.arabpixel.net/) over **HTTP**, pick a **Linux Loader** (for example 1GB), and send. GoldHEN PayLoader must already be running. Do not use GitLab Pages HTTPS for this — the browser cannot reach `http://127.0.0.1:9090` from HTTPS.

**From a PC (same LAN):**

```bash
nc -q 1 <PS4-IP> 9090 < linux-1024mb.elf
```

On Windows, send the ELF with a raw TCP client to `<PS4-IP>:9090`.

4. Watch the console power LED:
   - **Blue** = Linux booted successfully (this is the only good sign that Linux is running on the console).
   - **White** for more than about **30 seconds** = Linux did not boot. Do a full power off and retry (or try the other kernel).
5. When it works, it logs in automatically and goes straight to the KDE desktop.

### 5. Expand the root partition

Check the names with `lsblk` (the USB was `sdb` here), then:

```bash
sudo parted /dev/sdb resizepart 2 100%
sudo resize2fs /dev/sdb2
```

Alternatively, grow partition 2 to the end of the drive with a partition editor such as GParted on another Linux PC.

### 6. After installation

- **DualShock 4:** works over USB. Over Bluetooth it must be paired again on every boot.
- **Network:** Ethernet works out of the box. Wi-Fi is still in testing - prefer 2.4GHz. If it is stuck on "Configuring interface":

```bash
sudo nmcli con modify "SSID" wifi.cloned-mac-address permanent wifi.powersave 2
```

- **Back to Linux after a reboot:** rebooting returns to the PS4 system. Jailbreak, plug in the USB and send the payload again.

## Troubleshooting

- **Power LED:** **blue** = Linux is up on the console. If the light stays **white** for more than about **30 seconds**, Linux did not boot.
- **White light / black screen (failed boot):** do a full power off (hold the power button), wait a few seconds, jailbreak again and retry. The 2nd or 3rd try usually works. If it stays white every time, try the other kernel (Belize ↔ Baikal).
- **Best routine:** plug the USB in before powering on. Send the ELF right after the jailbreak, without opening games or apps.
- **Rescue shell with `mounting LABEL=psxitarch failed`:** the USB was not connected or detected. Plug it in and reboot (resume-boot does not help).
- **Sleep / suspend is not supported:** already disabled in the ready-made USB image (suspend, screen dimming and screen off are turned off). If you build your own image, disable it in KDE Power Management, or run:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

- **Pasted commands add junk characters:** type them by hand.

## Credits

- **fail0verflow (marcan, shuffle2)** - original PS4 Linux kernel port and ps4-kexec (the base of the loader)
- **rancido and PSXITA Team, eeply, valeryy, tihmstar, mircoho, codedwrench, crashniels** - PS4 kernel patches (amdgpu, Pro/Slim video, HDMI audio, Baikal and Belize support) carried into today's kernels
- **rmuxnet** - Strawberry kernels (7.1.7 Aeolia/Belize, Baikal port to 7.0.8) and the firmware/southbridge agnostic loader rework
- **ps4boot** - original ps4-linux-payloads loader
- **ArabPixel** - ps4-linux-loader maintainer, FW 12.5x and 13.00-13.52 support
- **PSXITA Team (Rancido)** - Psxitarch v3 initramfs and install scripts
- **Piotr Karbowski** - better-initramfs
- **Erkkola (ErkkolaMaitohappo)** - Arch Linux KDE v1.1.1 rootfs
- **centi07 and DionKill** - PS4 patched Mesa and video driver packages
- **SiSTR0** - GoldHEN (jailbreak, FTP server, BinLoader)

Kernels, payloads and initramfs are unmodified and belong to their authors.