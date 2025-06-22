
# 🛠️ Optimize Windows Settings Scripts Collection

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![PowerShell](https://img.shields.io/badge/powershell-5.1%2B-blue.svg)
![Version](https://img.shields.io/badge/version-1.0-green.svg)

## 📘 Overview

This repository provides a powerful suite of PowerShell scripts designed to **optimize, maintain, and clean Windows operating systems**. These scripts are tailored for IT administrators, system engineers, or power users looking to automate PC tuning, debloat unnecessary apps, clean system junk, and improve overall performance.

All scripts are portable and can be used locally or deployed via **Microsoft Intune**, **Group Policy**, or **manual execution**. Logging, safety checks, and modular functions are implemented across scripts for professional-grade reliability.

---

## 📂 Scripts Included

### 1. `Optimize-WindowsSettings.ps1`

#### ✅ Purpose
Optimizes key Windows settings for performance, user experience, and reduced telemetry.

#### ⚙️ Features
- Disables telemetry & data collection services.
- Removes background apps and disables unnecessary services.
- Tweaks visual effects for better performance.
- Disables Cortana, task suggestions, and lock screen tips.

#### 💡 Example
```powershell
.\Optimize-WindowsSettings.ps1
````

---

### 2. `PCMaintenance.ps1`

#### ✅ Purpose

Performs essential PC maintenance tasks with one-click execution.

#### ⚙️ Features

* Runs `SFC /scannow` for system file integrity.
* Runs `DISM /Online /Cleanup-Image` to fix system image corruption.
* Flushes DNS cache and resets network stack.
* Removes temporary files and minidump logs.
* Automatically logs output to a timestamped log file.

#### 📄 Output

A detailed maintenance log file saved to:

```
C:\Intune\PCMaintenance_<timestamp>.log
```

---

### 3. `SystemCleanup.ps1`

#### ✅ Purpose

A full remediation and cleanup script to delete junk files and caches.

#### ⚙️ Cleans the following:

* Windows Temp
* User Temp
* Windows Update Cache
* Internet Explorer Cache
* Recycle Bin
* Windows Error Reporting files
* Chrome, Edge, Firefox, Waterfox browser caches
* Microsoft Teams cache

#### 📋 Advanced Capabilities

* Stops browser processes before cleaning
* Measures disk usage before and after cleanup
* Logs all actions to `C:\Intune\SystemCleanup_<timestamp>.log`

#### 💡 Example

```powershell
.\SystemCleanup.ps1
```

---

### 4. `WindowsBloatware.ps1`

#### ✅ Purpose

Identifies and removes unnecessary built-in apps and UWP bloatware.

#### ⚙️ Features

* Lists all provisioned and installed apps
* Provides options for removing apps silently or interactively
* Supports exporting app lists for auditing
* Can be Intune-packaged for automatic deployment

#### 📄 Output

Exports before/after app list to CSV for auditing.

---

## 🚀 How to Run

1. **Open PowerShell as Administrator**
2. Navigate to the script folder:

   ```powershell
   cd "C:\Users\YourUser\Desktop\Scripts\Optimize-WindowsSettings"
   ```
3. Run the desired script:

   ```powershell
   .\SystemCleanup.ps1
   ```

---

## 💼 Use Cases

| Use Case            | Script                                                 |
| ------------------- | ------------------------------------------------------ |
| Intune Deployment   | `SystemCleanup.ps1`, `WindowsBloatware.ps1`            |
| New PC Setup        | `Optimize-WindowsSettings.ps1`, `WindowsBloatware.ps1` |
| Monthly Maintenance | `PCMaintenance.ps1`, `SystemCleanup.ps1`               |
| Performance Tuning  | `Optimize-WindowsSettings.ps1`                         |

---

## 📁 Folder Structure

```
Optimize-WindowsSettings\
│
├── Optimize-WindowsSettings.ps1       # Performance tweaks
├── PCMaintenance.ps1                  # Monthly health checks
├── SystemCleanup.ps1                  # Full cache/temp cleanup
└── WindowsBloatware.ps1               # UWP and system app remover
```

---

## 🧠 Requirements

* PowerShell 5.1+
* Run as **Administrator**
* For Intune: Package `.ps1` in `.intunewin` or use as Remediation Script

---

## 🔒 Security Notice

These scripts:

* Do **not** send data externally.
* Do **not** modify user data or critical system drivers.
* Log every action performed to allow full traceability.

---

## 👨‍💻 Author

**Mohammad Abdelkader**
🔗 [momar.tech](https://momar.tech)
📆 Last Updated: 2025-06-22
📜 License: [MIT License](https://opensource.org/licenses/MIT)

---

> 📌 **Disclaimer**: Test all scripts in a controlled environment before deploying in production. The author is not responsible for any unintended behavior caused by script misuse.
