# EmojiGo（Ficial Dash Match）
## **Group Member**
Tong Li  
Ping He  
Shuangling Zhao
## **Description**
This game is a tunnel adventure game based on facial expression recognition. Players use the camera to capture their facial expressions in real time and match them with the emojis displayed on randomly appearing obstacles in the tunnel. 

- The obstacles may feature several possible emojis, such as a **happy face**, a **fearful face**, or a **surprised face**.  
- When the player’s expression matches the emoji on the obstacle, they **successfully pass through** and continue advancing.  
- The goal is to **avoid all obstacles** and complete the tunnel.  
- The game is simple and intuitive to play, offering both **fun and challenges** through real-time interactions.
---
## **Contents**
- **EmojiGo**
  - **AR**
    - ARSetup
  - **Controller**
    - ViewController
  - **CoreML**
    - EmojiChallengeClassifier
    - EmotionAnalyzer
    - ImagePreprocessor
  - **Model**
    - GameModel
  - **View**
    - FloorAndPlankView
    - GameView
    - HomeViewController
  - AppDelegate
  - **art**
  - **Assets/**
    - failure.wav
    - success.wav
  - LaunchScreen
  - Main



## **Constraints**

### 1. **Real-Time Facial Expression Recognition**
- The game uses the **front-facing camera** to capture the player’s facial expressions in real time.
- Facial expression recognition is implemented using:
  - **CoreML** and **Vision** frameworks.
  - Based on **facial landmarks** for accurate expression classification.
- Supports the classification of **three expressions**:
  - 😨 **Fear**  
  - 😊 **Happy**  
  - 😲 **Surprise**

---

### 2. **Low-Light Environment Optimization**
- Real-time video capture will be optimized for **low-light conditions**.
- Techniques to improve recognition in low-light:
  - **Brightness adjustment** of the video frames.
  - **Contrast enhancement** for better facial feature detection.
  - Adaptive threshold adjustments for the Vision framework.

---

### 3. **Dynamic Obstacle Generation**
- Obstacles will be **randomly generated** in the tunnel.
- Obstacles appear at a **fixed interval** of **3 seconds**.
- Each obstacle features a randomly selected emoji:
  - 😨 **Fear**  
  - 😊 **Happy**  
  - 😲 **Surprise**  
- Players must match their facial expressions to the emoji on the obstacle to **pass through successfully**.

---

### 4. **Dynamic Animations and Immersive Effects**
- Smooth and **seamless animations** for obstacles and background transitions.
- Obstacles dynamically move toward the player, creating an immersive experience.
- Successful or failed matches trigger:
  - **Success animation** + sound effect (e.g., ✔️ checkmark).
  - **Failure animation** + sound effect (e.g., ❌ cross mark).

---

### 5. **Sound Effects**
- The game will include distinct **sound effects** for:
  - **Success**: Indicates a match (e.g., ✅ Positive chime).
  - **Failure**: Indicates a mismatch (e.g., ❌ Negative buzzer).
- Sound effects are integrated to provide immediate feedback for players.

---

### 6. **Gameplay Objective**
- Players must **match their facial expression** with the emoji displayed on the obstacle.
- Successful matches allow the player to:
  - Continue advancing through the tunnel.
  - Earn **points** for each successful match.
- The goal is to **avoid all obstacles** and reach the end of the tunnel.

---

## **Technologies Used**
- **CoreML**: For machine learning-based facial expression recognition.
- **Vision**: For processing real-time video frames and facial landmarks.
- **ARKit/SceneKit**: To handle dynamic animations and smooth obstacle transitions.
- **AVFoundation**: To integrate real-time video capture and sound effects.
- **Swift Programming Language**: The primary language for implementation.

---

## **Summary**
This tunnel adventure game combines **real-time facial expression recognition**, dynamic animations, and smooth sound effects to create an interactive and immersive gameplay experience. Players must rely on their expressions to match the displayed emojis and navigate through the tunnel. The game offers both challenges and fun, encouraging real-time interaction and reflex-based gameplay.

---
