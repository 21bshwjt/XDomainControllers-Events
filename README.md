<h1 align="center">🔍 Hunt Weaker Ciphers & Authentication Protocols</h1>
<p align="center">
  <b>PowerShell module to detect weak authentication protocols, cipher usage, account lockouts, and Domain Controller health — across your entire AD forest.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%20Server-0078D4?style=flat-square&logo=windows&logoColor=white"/>
  <img src="https://img.shields.io/badge/Language-PowerShell-5391FE?style=flat-square&logo=powershell&logoColor=white"/>
  <img src="https://img.shields.io/badge/Module-XDomainControllers--Events%20v1.3-blueviolet?style=flat-square"/>
  <img src="https://img.shields.io/badge/Gallery-PSGallery-0099CC?style=flat-square&logo=powershell&logoColor=white"/>
  <img src="https://img.shields.io/badge/Requires-Domain%20Admin-red?style=flat-square"/>
</p>

---

## 📋 Overview

Legacy authentication protocols like **NTLM** and weak ciphers like **RC4** remain active in many Active Directory environments — often silently — creating significant security exposure. This PowerShell module hunts them down across all Domain Controllers using **Windows Event Logs via WinRM**, giving you actionable visibility without deploying any agents.

| Capability | Description |
|---|---|
| 🔐 **RC4 Detection** | Identify sources using the weak RC4 encryption cipher for Kerberos |
| 🔑 **NTLM Detection** | Surface clients and services still authenticating over NTLM |
| ✅ **AES Detection** | Confirm sources correctly using AES Kerberos encryption |
| 🔒 **Account Lockout** | Trace the origin of account lockout events |
| ⏱️ **DC Uptime** | Report uptime across all Domain Controllers in the forest |
| 🩹 **Patch Status** | Retrieve the last Windows Update date per Domain Controller |

---

## ⚙️ Prerequisites

| Requirement | Details |
|---|---|
| PowerShell | 5.1 or later |
| WinRM | Must be enabled and reachable on all Domain Controllers |
| Module | `ActiveDirectory` (RSAT) |
| Privilege | **Domain Admin** — required to query DC event logs remotely |
| Source | [PSGallery](https://www.powershellgallery.com/) |

---

## 📦 Installation

```powershell
# ── Step 1: Install the module from PSGallery ────────────────────
Install-Module -Name XDomainControllers-Events `
               -RequiredVersion 1.3 `
               -Force `
               -Verbose `
               -Repository PSGallery

# ── Step 2: Import into your session ────────────────────────────
Import-Module XDomainControllers-Events -Verbose

# ── Step 3: Verify available commands ───────────────────────────
Get-Command -Module XDomainControllers-Events
```

**Available Functions:**

```
CommandType   Name                  Version   Source
-----------   ----                  -------   ------
Function      Get-XhuntAES          1.3       XDomainControllers-Events
Function      Get-XhuntLockout      1.3       XDomainControllers-Events
Function      Get-XhuntNtlm         1.3       XDomainControllers-Events
Function      Get-XhuntRC4          1.3       XDomainControllers-Events
Function      Get-XhuntUptime       1.3       XDomainControllers-Events
Function      Get-XhuntWUdate       1.3       XDomainControllers-Events
```

---

## 📖 Function Reference

---

### 🔐 `Get-XhuntRC4` — Hunt RC4 Cipher Usage

Identifies clients and services authenticating via Kerberos using the **RC4-HMAC** cipher (etype 23) — flagged as weak by Microsoft and disabled by default in Windows Server 2025+.

```powershell
Get-XhuntRC4
```

> 💡 **Why it matters:** RC4 is considered cryptographically weak and is a common target in **Kerberoasting** attacks. Any source appearing here should be prioritised for remediation.

---

### 🔑 `Get-XhuntNtlm` — Hunt NTLM Authentication

Surfaces all NTLM authentication events logged on Domain Controllers — revealing legacy clients, services, or applications that have not migrated to Kerberos.

```powershell
Get-XhuntNtlm
```

> 💡 **Why it matters:** NTLM is vulnerable to **Pass-the-Hash** and **relay attacks**. Reducing NTLM usage is a foundational step in hardening AD environments.

---

### ✅ `Get-XhuntAES` — Verify AES Kerberos Usage

Returns sources actively using **AES-128 or AES-256** Kerberos encryption — confirming compliant, modern authentication behaviour.

```powershell
Get-XhuntAES
```

> 💡 Use this to validate remediation progress after suppressing RC4 or NTLM usage.

---

### 🔒 `Get-XhuntLockout` — Trace Account Lockout Sources

Queries Domain Controller Security event logs to identify the **originating source** (workstation, server, or process) triggering account lockouts.

```powershell
Get-XhuntLockout
```

> 💡 Useful for resolving recurring lockouts caused by cached credentials, stale sessions, or mapped drives.

---

### ⏱️ `Get-XhuntUptime` — Domain Controller Uptime

Reports the current uptime of every Domain Controller in the forest — useful for identifying DCs that may have missed a planned restart after patching.

```powershell
Get-XhuntUptime
```

---

### 🩹 `Get-XhuntWUdate` — Last Patching Date

Retrieves the **last successful Windows Update date** from all Domain Controllers, enabling quick identification of machines falling behind on patch cycles.

```powershell
Get-XhuntWUdate
```

---

## 🗺️ Use Case Workflow

```
 Run Get-XhuntRC4          ──▶  Identify RC4 sources  ──▶  Enforce AES-only policy
 Run Get-XhuntNtlm         ──▶  Identify NTLM sources ──▶  Move to Kerberos / block NTLM
 Run Get-XhuntAES          ──▶  Confirm AES adoption   ──▶  Validate remediation
 Run Get-XhuntLockout      ──▶  Find lockout origin    ──▶  Fix cached credentials
 Run Get-XhuntUptime       ──▶  Flag stale DCs         ──▶  Schedule maintenance
 Run Get-XhuntWUdate       ──▶  Identify unpatched DCs ──▶  Trigger patch deployment
```

---

## 🔐 Security Context

> ⚠️ **Domain Admin privilege is required.** This module queries Security and System event logs on Domain Controllers remotely over **WinRM**. Ensure WinRM is enabled and firewall rules permit access from the machine running the module.

```powershell
# Verify WinRM connectivity to a DC before running
Test-WSMan -ComputerName "DC01.yourdomain.com" -Authentication Default
```

---

## 📚 Further Reading

- 📖 [Kerberos RC4 / AES Encryption in Windows](https://learn.microsoft.com/en-us/windows-server/security/kerberos/kerberos-and-kerberos-windows) — Microsoft Docs
- 📖 [NTLM Overview](https://learn.microsoft.com/en-us/windows-server/security/kerberos/ntlm-overview) — Microsoft Docs
- 📖 [Configuring WinRM](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management) — Microsoft Docs
- 📖 [Account Lockout Tools and Settings](https://learn.microsoft.com/en-us/troubleshoot/windows-server/identity/account-lockout-troubleshooting) — Microsoft Docs
- 📖 [XDomainControllers-Events on PSGallery](https://www.powershellgallery.com/packages/XDomainControllers-Events/1.3)

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
