# LimaLink: Final Presentation Strategy

Securing the full 40% for the presentation requires moving away from heavy text and focusing on **visuals**, your **problem-solving logic**, and a **live technical demonstration**. Evaluators want to see that you truly built the system and understand the engineering behind it.

Here is a straight-to-the-point, winning strategy.

## 1. Golden Rules for the Slides
- **No paragraphs.** Use bullet points (max 5 per slide). You will *speak* the details.
- **Use Diagrams.** Use the conceptual framework image we generated earlier and screenshots of your app.
- **Rule of 10-20-30:** Aim for about 10-15 slides, lasting 15-20 minutes, using a large font size (at least 24pt).

---

## 2. Slide-by-Slide Blueprint & Script

### Slide 1: Title Slide
*   **Visual:** The title of the project, your name, reg number, and the University logo.
*   **Script:** "Good morning panel. My name is Abednego Kaume. Today, I am presenting my final year project: LimaLink, an Uber-like platform for farm-ploughing tractors with real-time tracking and digital payments."

### Slide 2: The Problem
*   **Visual:** 2 contrasting bullet points or images (Idle tractor vs. Farmer digging manually).
*   **Script:** "In rural Kenya, we have a paradox. Smallholder farmers suffer from delayed land preparation because they can't find tractors. At the exact same time, tractor owners suffer from equipment underutilization because they can't locate the demand. The current scheduling system is manual, informal, and highly inefficient."

### Slide 3: The Solution (LimaLink)
*   **Visual:** A mock-up image of the Farmer App next to the Operator App.
*   **Script:** "To solve this, I developed LimaLink. It is a digital platform that brings the 'Uber' gig-economy model to agriculture. It connects farmers to nearby tractors in real-time, eliminating the middleman."

### Slide 4: Objectives
*   **Visual:** Bulleted list of the 4 specific objectives (Mobile App, Operator Module, Web Dashboard, Real-time tracking/Payments).
*   **Script:** "My objectives were to build a cross-platform mobile app for booking, a dedicated module for operators, a web dashboard for administrators, and crucially, to implement real-time GPS tracking and secure M-Pesa payments."

### Slide 5: Conceptual Framework
*   **Visual:** Insert the `conceptual_framework.png` we generated earlier.
*   **Script:** "This diagram illustrates the core of my study. By introducing independent variables like Real-Time Tracking and Digital Payments, we positively affect our dependent variables: reducing booking latency and increasing tractor utilization."

### Slide 6: System Architecture (The "Tech" Slide)
*   **Visual:** A diagram showing Flutter -> Node.js -> PostgreSQL -> Safaricom M-Pesa API.
*   **Script:** "For the methodology, I used an Agile approach. The system is highly decoupled. The frontend is built in Flutter for cross-platform mobile support. The backend is Node.js and Express, securely storing data in a PostgreSQL relational database."

### Slide 7: The "Magic" (WebSockets & M-Pesa)
*   **Visual:** Icons of Socket.io and M-Pesa.
*   **Script:** "To achieve the Uber-like feel, I implemented Socket.io. This establishes a persistent WebSocket connection, allowing the operator's phone to broadcast GPS coordinates to the farmer's phone every 3 seconds. For security, I integrated the Safaricom M-Pesa Daraja API for automated STK Push payments."

### Slide 8: Findings & Results
*   **Visual:** A simple bar chart or large numbers: "42 Seconds Average Wait", "96% Payment Success", "82.5 SUS Score".
*   **Script:** "The empirical testing was highly successful. The average booking latency dropped to just 42 seconds. M-Pesa transactions had a 96% success rate, and out of 15 test users, the system scored an 82.5 on the System Usability Scale, proving that traditional farmers can and will adopt this technology."

### Slide 9: LIVE DEMONSTRATION (Crucial for Marks)
*   **Visual:** "Live Demo" text on screen. 
*   **Action:** Have your laptop mirrored to the projector. Have the Farmer App open on an emulator and the Operator App open on another (or your physical phone). 
*   **Script:** "I will now demonstrate the system live. Watch as I request a tractor as a farmer... [click book]... and instantly, the operator receives the ping. Once accepted, you can see the live map updating."

### Slide 10: Conclusion & Recommendations
*   **Visual:** Bullet points summarizing the impact.
*   **Script:** "In conclusion, LimaLink proves that the Tractor-as-a-Service model is technically feasible and highly effective. I recommend this architecture be explored for other agricultural machinery like combine harvesters. Thank you. I welcome any questions."

---

## 3. How to Prepare
1. **Anticipate Technical Questions:** The panel will test if you actually wrote the code. Be ready to explain *how* WebSockets work, *how* you secured the M-Pesa callback URL, and *why* you chose PostgreSQL over a NoSQL database (Answer: ACID compliance for financial transactions).
2. **Practice the Demo:** The live demo is where students panic. Have your Docker containers running beforehand. Make sure your M-Pesa sandbox credentials haven't expired. Test the booking flow 5 times the morning of the presentation.
