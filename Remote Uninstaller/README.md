
# 🔥 Remote EXE/MSI Uninstaller
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Windows](https://img.shields.io/badge/OS-Windows-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)


A **PowerShell-based GUI tool** that allows administrators to **remotely uninstall EXE and MSI applications** from Windows machines. The tool ensures complete cleanup by **removing registry entries, stopping processes, deleting leftover files/folders**, and **cleaning up Start Menu shortcuts and AppData**.

## 🎯 Features

✅ **Remote App Uninstallation**: Lists and removes **EXE/MSI** apps from a remote Windows machine using PowerShell remoting.  
✅ **WPF GUI with Console Output**: Modern interface that logs real-time execution steps in a **console-like text area**.  
✅ **No UI Freezing**: Uses **`Start-Job`** to run uninstall operations asynchronously, keeping the UI responsive.  
✅ **Force Removal of Stubborn Apps**: Converts **MSI `/I` to `/x`**, ensures **silent parameters for EXE**, and **kills running processes** before uninstallation.  
✅ **WinGet Fallback**: If traditional uninstallation fails, it attempts **WinGet uninstall** as a backup method.  
✅ **Full Cleanup**:
   - **Removes leftover registry keys**  
   - **Deletes folders from Program Files (x86) & Program Files**  
   - **Cleans Start Menu shortcuts & folders**  
   - **Searches and deletes app-related files in user `AppData`**  
✅ **CSV Export**: Allows exporting a list of installed applications for auditing.  

---

## 📌 Requirements

🔹 **PowerShell 5.1+** (or later)  
🔹 **Run as Administrator** (required for modifying system files and registry)  
🔹 **PowerShell Remoting Enabled** on the remote machine  
🔹 (Optional) **WinGet installed** on the remote machine for fallback uninstall  

---

## 🚀 How to Use

### **1️⃣ Launch the Script**
Run the script **as Administrator**:
```powershell
PS C:\> .\UninstallManager.ps1
```

### **2️⃣ Use the GUI**
1. **Enter the remote PC name or IP** in the input box.
2. Click **📂 Load Applications** to retrieve a list of installed software.
3. **Select applications** from the list.
4. Click **🗑️ Uninstall Selected** to begin the removal process.
5. **Monitor real-time logs** in the output console.

### **3️⃣ Export Installed Apps**
Click **📄 Export to CSV** to save the list of installed applications for reporting.

---

## 🛠️ **How It Works**
1️⃣ **Retrieves Installed Applications**  
   - Queries registry locations for installed **EXE/MSI** software.  
   - Returns **Application Name, Publisher, Version, Install Date, and Uninstall String**.  
   
2️⃣ **Uninstalls Selected Applications**  
   - **Stops any running processes** matching the app name.  
   - Runs **MSIExec with `/x` and `/quiet` flags** for silent removal.  
   - Ensures **EXE uninstallation is silent** (`/S`, `/quiet`, `/silent`).  

3️⃣ **Cleans Up Leftovers**  
   - **Deletes registry keys** related to the app.  
   - **Removes the app’s installation folder** from **`Program Files`** and **`Program Files (x86)`**.  
   - **Deletes Start Menu shortcuts** that match the app name.  
   - **Searches `AppData` for lingering files** and removes them.

4️⃣ **WinGet Fallback (If Needed)**  
   - If the registry uninstall fails, checks if **WinGet** is installed.  
   - Runs `winget uninstall --name "AppName" --exact --silent`.  

---

## 🗑️ **Cleanup Details**
🔹 **Process Termination**: Stops running processes before attempting uninstall.  
🔹 **Registry Key Removal**: Deletes registry entries under:  
   - `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`  
   - `HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall`  
🔹 **Program Files Cleanup**: Deletes folders in:  
   - `C:\Program Files\AppName`  
   - `C:\Program Files (x86)\AppName`  
🔹 **Start Menu Cleanup**: Only removes **subfolders and shortcuts that match the app name**, rather than the entire “Programs” directory.  
🔹 **User AppData Cleanup**: Searches and removes `.exe`, `.lnk`, and leftover directories in:
   - `C:\Users\*\AppData\Roaming`
   - `C:\Users\*\AppData\Local`
   - `C:\Users\*\AppData\LocalLow`

---

## 🔍 **Known Issues & Troubleshooting**
**Q: The script fails to uninstall some apps. Why?**  
✔️ Some software doesn’t register an **UninstallString** in the registry. **WinGet** is required as a fallback.  

**Q: The app is removed, but its Start Menu shortcut remains.**  
✔️ Ensure the **AppData cleanup logic** correctly matches the folder name. Some apps store Start Menu entries under a different name.  

**Q: I see ‘⚠ Another uninstall job is already running. Please wait...’**  
✔️ The script prevents running multiple uninstall jobs simultaneously. Wait for the current process to finish before starting another.

**Q: WinGet commands fail on the remote machine.**  
✔️ Check if WinGet is installed (`winget --version`). If not, install it via:  
```powershell
Invoke-Command -ComputerName RemotePC -ScriptBlock { Get-AppxPackage -Name Microsoft.DesktopAppInstaller }
```

---

## 🔐 **Security Considerations**
⚠ **Test in a lab environment before production deployment.**  
⚠ PowerShell **Remoting must be enabled** on target machines.  
⚠ Requires **admin privileges** to remove protected software.  

---

## 📄 License
This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.

---

## ❤️ **Contributing**
👥 Want to improve the script? Fork this repo and submit a **pull request**!  

---

### 📌 **Example Screenshot (Optional)**
*(Attach a screenshot of the GUI here.)*

---

### 📢 **Disclaimer**
This script is provided **as-is**. Use it with caution, and **test in a non-production environment before deployment**. The author is **not responsible** for unintended modifications or data loss.

