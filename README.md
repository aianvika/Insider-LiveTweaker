<div align="center">
  <h1>🔧 Insider-LiveTweaker</h1>
  <p><b>Live System Tweaker for Windows 11 Insider Preview Builds</b></p>
  <p><i>Insider Watermark Removal • Evaluation Build Expiration Management • Portable • No Installation</i></p>
  <p>
    <img src="https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell" />
    <img src="https://img.shields.io/badge/Platform-Windows%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows 11" />
  </p>
</div>

---

## 🔧 What Is Insider-LiveTweaker?

**Insider-LiveTweaker is a portable, open-source PowerShell tool with a native GUI that applies live, on-the-fly tweaks to a running Windows 11 Insider Preview installation.**

If you run **Windows 11 Insider Preview builds**, you know the two annoyances that come with the territory: the **"Evaluation Copy — Build XXXXX" watermark** in the corner of your desktop, and the **build expiration countdown** ("timebomb") that eventually makes the OS unusable. Insider-LiveTweaker handles both — no reinstall, no command-line gymnastics, no third-party "optimization suite."

It's a single readable script with a GUI, runs in seconds, works fully offline, and is validated against the latest Insider builds — including **build 29648.1000**.

---

## ⚡ Features

- 💧 **Watermark Removal** — clears the desktop **Evaluation Copy watermark** and the `winver` expiration text, live, without logging out
- ⏳ **Timebomb Defuser** — updates the system licensing policy so the Insider evaluation expiration date no longer applies to your installation
- 🧠 **In-memory patching** — watermark patches are applied to running memory with structural file offsets preserved; on-disk system binaries are untouched *(see How It Works)*
- 🪟 **Native GUI** — pick your tweaks, click Apply; no installation, no dependencies, nothing left running afterward
- 🧰 **Open source & offline** — a readable PowerShell script; nothing downloaded, nothing uploaded, no binaries shipped
- 🆕 **Kept current** — validated against the newest Insider builds (older Win10-era watermark tools break on modern builds)

---

## 🔬 How It Works (Technical)

**Watermark Removal:** applies a surgical, in-memory patch to the system DLL responsible for painting the desktop watermark — modifying the Unicode string data at the byte level while preserving all structural offsets, so the patch never breaks the module. Because it's in memory, on-disk files stay byte-identical.

**Timebomb Defuser:** Insider evaluation builds carry an expiration term inside their **licensing policy tokens** used by the Software Protection Service (`sppsvc`). The defuser swaps those evaluation tokens for **retail policy tokens**, which contain no expiration terms — the timebomb simply no longer applies.

---

## 📸 Screenshot

![Insider-LiveTweaker GUI](docs/gui-screenshot.png)

---

## 📥 Prerequisites

The **Timebomb Defuser** requires you to manually supply a Retail policy file:

1. Extract `pkeyconfig.xrm-ms` from any standard (non-evaluation) **Windows 11 Retail or LTSC ISO**.
2. Place `pkeyconfig.xrm-ms` directly in the project folder, next to the `.ps1` script.

> The watermark removal feature works standalone — no extra files needed.

---

## 🛠️ Usage

1. Open PowerShell as Administrator and temporarily allow script execution:
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    ```
2. Right-click `Insider-LiveTweaker.ps1` and select **Run with PowerShell**.
3. Select your desired tweaks from the GUI and click **Apply**.
4. The tool applies the changes and restarts the necessary system services for the changes to take effect.

---

## ❓ FAQ

**Q: What is the Insider "timebomb"?**
Every Insider Preview build ships with a built-in expiration date (typically ~10–12 months after release). As expiration approaches you get watermark nagging; after expiration, Windows enters a degraded state with forced periodic restarts. The intended fix is moving to a newer build — LiveTweaker instead removes the expiration term from the licensing policy.


**Q: Does Insider-LiveTweaker activate Windows?**
**No.** This is not an activation tool and it does not provide free Windows licenses. A legitimate product key or digital license is still required to activate the OS. LiveTweaker only modifies evaluation-expiration terms and cosmetic watermarks on builds you're entitled to run as an Insider.


**Q: Does it modify system files on disk?**
The watermark patch is applied entirely in memory — on-disk binaries are never modified, and structural offsets are preserved. The Timebomb Defuser updates the licensing policy as described in *How It Works*.

**Q: Does this work on stable/retail Windows 11?**
The tool is designed and tested for Insider Preview builds. Stable retail installations have no timebomb and no evaluation watermark — there's nothing for LiveTweaker to do there.

**Q: Is Insider-LiveTweaker safe?**
No binaries ship with it. It's a readable PowerShell script running offline on your own machine — every line of what it does is auditable before you run it.

---

## ⚠️ Read Before Using

- Insider builds are **pre-release software** — Microsoft expects testers to rotate to newer builds; extending a build means running aging pre-release code at your own risk.
- This tool **modifies built-in technical limitations** of the operating system, including the Software Protection Platform (SPP). Understand what the tool does (everything is in the open-source script) before applying it.
- **This is not an activation tool.** It provides no free Windows licenses — legitimate activation is still required.

---

## ⚠️ Disclaimer & Legal
- This project is provided strictly for **educational and personal research purposes**, for use on **your own** Insider Preview installation.
- **Commercial distribution of modified Insider builds violates the Microsoft EULA.** Do not redistribute Windows images.
- This tool does *not* provide free Windows licenses; a legitimate product key or digital license is strictly required to activate the OS.
- Insider-LiveTweaker is an independent, unofficial project and is not affiliated with or endorsed by Microsoft.
- Windows is a trademark of Microsoft Corporation. Use at your own risk — no warranties, express or implied.

---
<div align="center">
  <i>Tweak the build you run. Not the rules you agreed to.</i>
</div>
