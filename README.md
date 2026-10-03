# PS4 Linux

Run Linux (Arch Linux with KDE Plasma) on a jailbroken PS4 from a USB drive. Tested setup, ready-to-use files.

This file contains the latest Linux update, dated 29/09/2026.

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
- Easiest check: if the Belize kernel gets a white light every time, use the Baikal kernel.
- On the console, the kernel must always be named `/data/linux/boot/bzImage`.
- Do not put a file named `bzImage` on the USB. The loader prefers a USB kernel over `/data/linux/boot/`, so leave it off and one USB works on every console.

## Download

Get everything from [Releases](../../releases/latest). Unzip `kernel.zip`, `payloads.zip`, and `tools.zip` first. Leave `psxitarch.tar.xz` as its own file.

| File | What it is |
|---|---|
| `psxitarch.tar.xz` | The compressed Linux file. 2.8 GB (2962027772 bytes). |
| `kernel.zip` | Kernels and the small boot file. 36.4 MB (38147462 bytes). Unzip it to get `kernel/`. |
| `payloads.zip` | The files you send to the PS4. 0.2 MB (189240 bytes). Unzip it to get `payloads/`. Use `payloads/linux-1024mb.elf`. |
| `tools.zip` | Scripts that build and burn the USB, plus checksums. 0.0 MB (5089 bytes). Unzip it to get `tools/`. |

Do not put a file named `bzImage` on the USB. The PS4 would boot that file instead of the kernel that matches the console. One USB then works for both Belize and Baikal.

## Which USB

- Best: a 32GB USB 3.0 stick. Fast, and there is room left after Linux is installed.
- Minimum: 16GB. It fits, but there is almost no free space until you grow the partition.
- Slower USB 2.0 sticks work, but boot and the desktop feel slow.

Burning erases the whole stick.

## Install

### 1. Make the USB image

Unzip `kernel.zip` and `tools.zip` first. On Linux or Windows WSL, with `psxitarch.tar.xz` in the same folder:

```bash
sudo bash tools/build-img.sh psxitarch.tar.xz kernel/initramfs.cpio.gz psxitarch-usb.img
```

You get `psxitarch-usb.img`, about 12GB. That is the file you burn.

### 2. Burn it

**Windows**

1. Open PowerShell as Administrator.
2. Run `Get-Disk` and note the number of the USB stick. Do not pick your PC disk.
3. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\write-img.ps1 -ImagePath .\psxitarch-usb.img -DiskNumber 1
```

Change `1` to your USB number. If Windows asks to format the stick, click Cancel.

You can also burn `psxitarch-usb.img` with balenaEtcher, or with Rufus in DD mode.

**Linux**

Find the stick with `lsblk`. Replace `sdX` with that name, not a partition like `sdX1`:

```bash
sudo dd if=psxitarch-usb.img of=/dev/sdX bs=4M status=progress conv=fsync
```

### 3. Use the whole stick

The burned Linux partition is only about 12GB. On a 32GB or larger stick, grow it so the free space is usable. Check the name with `lsblk` (here it was `sdb`):

```bash
sudo parted /dev/sdb resizepart 2 100%
sudo resize2fs /dev/sdb2
```

### 4. Put the kernel on the PS4

The kernel stays on the console, not on the USB.

1. Jailbreak with GoldHEN.
2. FTP to the PS4, port `2121`.
3. Create the folder `/data/linux/boot/`.
4. Upload the kernel for your console and name it `/data/linux/boot/bzImage`.
5. Upload `kernel/initramfs.cpio.gz` to `/data/linux/boot/initramfs.cpio.gz`.

Belize uses `kernel/bzImage-belize-7.1.7`. Baikal uses `kernel/bzImage-baikal-7.0.8`. If a Belize kernel only gives a white light, use the Baikal one.

### 5. Boot

1. Plug the USB into the PS4 before you turn it on.
2. Jailbreak.
3. Send `payloads/linux-1024mb.elf` to the loader:

```bash
nc -q 1 <PS4-IP> 9020 < payloads/linux-1024mb.elf
```

If port 9020 does not answer, try 9090. A black screen for a minute or two is normal. It then logs in to the KDE desktop.

After a reboot you are back on the PS4. Jailbreak and send the payload again. The USB can stay plugged in.

## Payloads

| File | VRAM | Use |
|---|---|---|
| `linux-32mb.elf` to `linux-512mb.elf` | 32-512MB | No desktop. Server only. |
| `linux-1024mb.elf` | 1GB | Use this for the desktop. Tested on Pro and Slim. |
| `linux-2048mb.elf` | 2GB | More graphics memory. |
| `linux-3072mb.elf` | 3GB | Not tested. |
| `linux-4096mb.elf` | 4GB | Tested on Pro (FW 13.52). Heavy games and emulators. Leaves about 4GB RAM. |

## After it boots

- The controller works on a USB cable. Bluetooth has to be paired again after every boot.
- Ethernet works. Wi-Fi is still being tested. Prefer 2.4GHz.
- Sleep is turned off. Suspending the console breaks this Linux.

## Troubleshooting

- **Black screen or white light:** Linux does not always start after the jailbreak. This is normal. Do a full power off (hold the power button), wait a few seconds, jailbreak again and retry. The 2nd or 3rd try usually works.
- **Best routine:** plug the USB in before powering on. Send the ELF right after the jailbreak, without opening games or apps. Wait 1-2 minutes on a black screen before giving up.
- **White light every time:** probably the wrong kernel for your southbridge - try the other one.
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