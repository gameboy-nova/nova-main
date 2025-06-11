## NOVA GameBoy 🎮
## 📜 Overview

**"NOVA Gameboy"** is a custom-built, retro-inspired handheld console powered by the **STM32F401 "Black Pill"** and written entirely in **32-bit ARM Assembly**.  
Featuring a vibrant **2.8" TFT display**, physical gamepad input, and a sleek in-system game launcher, it brings classic games like **Snake**, **Pong**, and **Space Shooter** to life with **bare-metal performance** and **pixel-accurate graphics**.

Engineered without an OS or high-level libraries, this project is a full demonstration of **real-time embedded systems**, showcasing **manual hardware control**, **modular game architecture**, and **smooth 2D rendering**—all running directly on the **ARM Cortex-M4**.  
It’s not just a console—it’s a hands-on journey into the world of **low-level game development** and **embedded design**.


---

## 🧰 Hardware Requirements

| Component        | Specification                                        |
|------------------|------------------------------------------------------|
| **MCU**          | STM32F401RCT6 (Black Pill – ARM Cortex-M4 @ 84 MHz)  |
| **Debugger**     | ST-Link V2 (for programming and debugging)           |
| **Display**      | ILI9341 (2.8" TFT LCD – parallel interface)          |
| **Breadboards**  | 80-pin and 40-pin solderless breadboards             |
| **Input**        | Push buttons and switches (physical GPIO input)      |
| **Wiring**       | Jumper wires (male-to-male and male-to-female)       |
| **Resistors**    | Assorted values (used for pull-up/pull-down configs) |
| **Audio**        | Passive buzzer (for simple sound output)             |


---

## 🔧 Development Setup

- **Programming Language**: 32-bit ARM Assembly
- **IDE**: [Keil µVision](https://www.keil.com/)
- **Toolchain**: Keil ARM Compiler
- **Display Interface**: GPIO (FSMC or bit-banged parallel)
- **Input Interface**: GPIO with polling or interrupt support

---

## 📋 Features

- 🎮 Dual-player gamepad input system with independent controls  
- 🚀 Menu-driven multi-game launcher with instant switching  
- 🖼️ Custom 2D graphics engine with pixel-perfect rendering  
- 🎨 Sprite and UI engine for smooth animation and effects  
- 🧩 Modular architecture with isolated game modules  
- 🔄 Seamless in-game switching without system reset  
- ⏱️ Hand-tuned delay and timing routines for consistent gameplay  
- ⚙️ Direct register-level control for all hardware I/O  
- 🔧 Fully bare-metal with zero OS or high-level libraries  
- 🧪 Expandable design for future games and features  


---

## 🚀 Getting Started
Set up and play in just a few steps:

---

### 📁 1. Clone the Repository  
Download the project by cloning this repository:

```bash
git clone https://github.com/gameboy-nova/nova-main.git
```

### 💻 2. Open the Project  
Launch **Keil µVision**, then open the (`Gameboy.uvprojx`) and you will be greeted with this window.
<p align="center">
<img src="https://github.com/user-attachments/assets/48828d0e-5a68-44f8-8bbb-2274001a2cfc" width="600">
</p>

### ⚙️ 3. Build the Firmware  
Click the **Build** button to compile the project using the **Keil ARM Compiler**.
<p align="center">
<img src="https://github.com/user-attachments/assets/939afddb-2cb8-4714-8fd0-c13f8380a48e" width="600">
</p>

#### 🛠️ 4. Connect Your Board  
Plug the **STM32F401RCT6 (Black Pill)** into your PC using the **ST-Link V2 programmer**.

<p align="center">
<img src="https://github.com/user-attachments/assets/a8636ef5-46d6-47fc-9ade-66df8cc9b2e1" width="600">
</p>

### 🔁 5. Flash the Board  
Use the **Flash** button to upload the compiled binary to the STM32 via ST-Link.
<p align="center">
<img src="https://github.com/user-attachments/assets/ad1babb4-5d07-4a65-b7e4-49a30a107777" width="600">
</p>

### 🎮 6. Play the Games!  
After flashing, the console boots into the game launcher. Use the **physical push buttons** to navigate and play!

<p align="center">
<img src="https://github.com/user-attachments/assets/0f9516c0-d3fd-4116-a6c9-9b7ddadb20d5" width="600">
</p>
