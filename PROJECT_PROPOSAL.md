# PRELIMINARY PAGES

## TITLE PAGE
**AN UBER-LIKE PLATFORM FOR FARM-PLOUGHING TRACTORS WITH REAL-TIME TRACKING AND DIGITAL PAYMENTS**

**ABEDNEGO KAUME**
**N11/3/0053/020**

**A RESEARCH PROPOSAL SUBMITTED TO THE COMPUTING AND INFORMATICS DEPARTMENT IN PARTIAL FULFILLMENT FOR THE AWARD OF THE DEGREE OF BACHELOR OF COMPUTER SCIENCE, LAIKIPIA UNIVERSITY**

**MARCH, 2026**

---

## DECLARATION
**Declaration by the candidate:**
This proposal is my original work and has not been presented for the award of a degree in any other University or for any other award.
Signature: …………………………. Date: ………………………………
Name: Abednego Kaume
Registration No: N11/3/0053/020

**Declaration by Supervisor:**
This proposal has been submitted for examination with my approval as the University Supervisor.
Signature: …………………………. Date: ………………………………
Name: [Supervisor's Name]
Department of Computing and Informatics, Laikipia University

---

## DEDICATION
This research is dedicated to the smallholder farmers in Kenya whose hard work, resilience, and unwavering dedication sustain our nation’s food supply. It is also dedicated to my family and friends for their continuous support, encouragement, and understanding throughout my academic journey. Their belief in the power of technology to transform lives has been a constant source of inspiration.

---

## ACKNOWLEDGEMENT
I wish to express my sincere gratitude to my supervisor for the invaluable guidance, constructive feedback, and continuous support during the conceptualization and formulation of this proposal. Special thanks to the Department of Computing and Informatics at Laikipia University for providing an enabling environment for research, learning, and innovation. I am also deeply grateful to the various agricultural cooperative members and tractor operators who provided early insights that shaped the problem statement and technical approach of this study. Finally, my heartfelt appreciation goes to all who, in one way or another, contributed to the successful completion of this research proposal.

---

## ABSTRACT
Mechanized farming is essential for increasing agricultural productivity and ensuring long-term food security. However, smallholder farmers face significant hurdles in accessing farm-ploughing tractors due to high costs, uneven geographical distribution, and highly inefficient scheduling systems. Similarly, tractor owners suffer from equipment underutilization, leading to diminished returns on heavy capital investments. This project proposes the development of "LimaLink," an "Uber-like" digital platform for farm-ploughing tractors. The system will connect farmers to available tractor operators in real-time, functioning as a multi-sided market that matches demand with supply efficiently. It will be implemented using a cross-platform Mobile Application (Flutter) for end-users and a Web Dashboard (React + Tailwind CSS) for administrative oversight. The backend will be powered by Node.js, Express, and PostgreSQL, featuring WebSockets (Socket.io) for live tractor location tracking and Safaricom's M-Pesa Daraja API for seamless, secure digital payments. By bridging the gap between demand and supply, this platform aims to optimize tractor utilization, reduce waiting times, automate scheduling, and improve overall crop yields. The study adopts an Applied Research design coupled with the Agile Software Development methodology, ensuring continuous refinement based on user feedback. The successful implementation of this platform is expected to provide a scalable, modern solution to traditional agricultural logistical bottlenecks, demonstrating the transformative potential of the digital platform economy in rural sectors.

---

## TABLE OF CONTENTS
1. TITLE PAGE
2. DECLARATION
3. DEDICATION
4. ACKNOWLEDGEMENT
5. ABSTRACT
6. CHAPTER ONE: INTRODUCTION
   - 1.1 Background to the Study
   - 1.2 Statement of the Problem
   - 1.3 Purpose of the Study
   - 1.4 Objectives of the Study
   - 1.5 Research Questions
   - 1.6 Significance of the Study
   - 1.7 Scope of the Study
   - 1.8 Limitation of the Study
   - 1.9 Definition of Key Terms
7. CHAPTER TWO: LITERATURE REVIEW
   - 2.1 Introduction
   - 2.2 Empirical Review
   - 2.3 Theoretical Review
   - 2.4 Conceptual Framework
   - 2.5 Summary and Research Gap
8. CHAPTER THREE: RESEARCH METHODOLOGY
   - 3.1 Introduction
   - 3.2 Research Philosophy
   - 3.3 Research Design
   - 3.4 Study Area
   - 3.5 Target Population
   - 3.6 Sampling Design
   - 3.7 Data Collection Instruments
   - 3.8 Data Analysis and Presentation
   - 3.9 System Development Methodology
9. REFERENCES
10. APPENDICES
    - Appendix I: Work Plan
    - Appendix II: Budget

---

# CHAPTER ONE: INTRODUCTION

## 1.1 Background to the Study
Agriculture remains the backbone of many developing economies, contributing significantly to the Gross Domestic Product (GDP) and providing livelihoods for a vast majority of the rural population. In Kenya, the agricultural sector is crucial, yet it operates significantly below its potential productivity levels. One of the primary factors contributing to this suboptimal performance is the low level of agricultural mechanization. Mechanized farming—specifically the use of tractors for land preparation, planting, and harvesting—plays a pivotal role in augmenting agricultural output and ensuring food security (Alene & Coulibaly, 2009). The introduction of machinery significantly reduces manual labor, speeds up operations, and is critical for maximizing seasonal planting windows, especially in regions affected by erratic weather patterns and climate change.

Despite the well-documented importance of mechanization, access to farming machinery in many rural areas of Kenya remains exceptionally low. Smallholder farmers, who account for the bulk of agricultural production, often struggle to locate, hire, and afford tractors when they need them the most (Kenya National Bureau of Statistics [KNBS], 2020). The high initial capital required to purchase a tractor means that ownership is typically concentrated among a wealthy minority, large-scale commercial farmers, or government-backed cooperatives. Consequently, the vast majority of smallholder farmers are dependent on a highly fragmented, informal, and localized rental market to access these services.

Conversely, owners of agricultural machinery frequently experience periods of severe equipment underutilization. An expensive asset like a tractor sitting idle represents a significant financial loss and a poor return on investment. The root cause of this dual problem—farmers lacking tractors and tractors lacking work—lies in the poor visibility and inefficient scheduling mechanisms inherent in the current system. The traditional approach to securing tractor services relies heavily on word-of-mouth, physical bulletin boards, or middlemen. This approach is not only highly inefficient but also prone to miscommunication, a lack of accountability, and artificially inflated pricing due to middleman markups.

In an era dominated by rapid digital transformation and the widespread penetration of mobile technology in rural Africa, there is a profound opportunity to revolutionize agricultural logistics. Applying the platform-economy model—popularized by ride-hailing services like Uber and Bolt, and accommodation services like Airbnb—presents a highly viable and innovative solution to the agricultural sector's logistical challenges. A digital platform can act as an intermediary, significantly lowering transaction costs, increasing transparency, and providing real-time matching of supply and demand. By leveraging technologies such as Global Positioning Systems (GPS), widespread mobile internet access, and localized mobile money solutions (like M-Pesa), it is now possible to create a "Tractor-as-a-Service" (TaaS) model that is both accessible to the smallest farmer and profitable for the machine owner.

## 1.2 Statement of the Problem
Despite the proven benefits of mechanized land preparation in boosting agricultural productivity, small and medium-scale farmers in rural Kenya continue to experience severe delays, high transaction costs, and immense frustration when attempting to hire farm-ploughing tractors. The heavy reliance on manual scheduling, informal agreements, and middlemen leads to unpredictable service delivery, a complete lack of transparent pricing, and difficulties in processing payments securely and reliably.

Simultaneously, tractor owners and operators suffer from significant underutilization of their expensive machinery due to an inability to efficiently locate, aggregate, and navigate to nearby farmers requiring their services. The absence of a centralized, real-time matching system results in lost time, excessive fuel wastage as tractors travel blindly searching for work, and reduced crop yields for farmers due to missed crucial planting seasons. Ultimately, this disconnect leads to diminished profitability for both farmers and tractor operators, stifling the economic growth of rural communities. There is an urgent, unresolved need for a robust, localized digital platform that can seamlessly connect tractor demand with supply in real-time, provide transparent tracking, and integrate secure digital payments.

## 1.3 Purpose of the Study
The primary purpose of this study is to design, develop, and evaluate a prototype digital platform named "LimaLink," which facilitates the real-time booking, sharing, and optimal utilization of farm-ploughing tractors for smallholder farmers and tractor operators in Kenya.

## 1.4 Objectives of the Study
### 1.4.1 General Objective
To develop and evaluate a comprehensive digital platform that optimizes the scheduling, real-time tracking, and payment processes for tractor ploughing services in rural agricultural settings.

### 1.4.2 Specific Objectives
1. To design and develop a cross-platform mobile application that allows farmers to view nearby available tractors, book ploughing services, and process digital payments securely via M-Pesa.
2. To build a dedicated operator module within the application enabling tractor owners to accept job requests, manage their schedules, broadcast real-time GPS location updates, and track earnings.
3. To develop a robust web-based administrative dashboard for system administrators to monitor platform metrics, verify user identities, manage disputes, and analyze geographical demand heatmaps.
4. To implement a secure, scalable backend architecture integrating WebSockets for live location tracking and third-party APIs for mobile money transactions.

## 1.5 Research Questions
1. How can the implementation of a digital platform optimize the scheduling, allocation, and utilization of tractor services among smallholder farmers?
2. What are the critical technical requirements and architectural considerations for implementing reliable real-time GPS tracking and M-Pesa digital payments in a rural agricultural mobile application?
3. To what extent does the proposed digital platform improve the operational efficiency, booking latency, and revenue generation for tractor owners and operators?

## 1.6 Significance of the Study
The realization of this digital platform carries profound significance for multiple stakeholders within the Kenyan agricultural value chain. 

For smallholder farmers, the system eliminates the chronic uncertainty and delays associated with finding farming equipment. By providing on-demand access to tractors, farmers can ensure timely land preparation, which directly translates to optimal planting, better crop yields, and increased food security. Furthermore, the transparency in pricing prevents exploitation by middlemen.

For tractor owners and operators, the platform provides a steady, aggregated stream of verifiable customers. This maximizes the utilization of their machinery, significantly increasing the return on their heavy capital investments. The integrated digital wallet and M-Pesa payment system ensure that operators are paid promptly and securely, reducing the risk of bad debts and cash handling issues.

Academically, this study bridges a critical gap by demonstrating the successful application of modern, advanced software engineering practices—specifically real-time bidirectional communication (WebSockets), secure third-party financial APIs, and scalable relational database management—to an underserved traditional sector. It provides empirical insights into how the digital platform economy can be adapted for rural agricultural logistics in developing nations.

## 1.7 Scope of the Study
The project focuses exclusively on the design, development, and initial evaluation of the software suite (comprising the Mobile App, Backend API, and Admin Dashboard) tailored specifically for the Kenyan agricultural sector. The system will primarily target the booking and management of farm-ploughing tractors, though the architecture will be scalable to other machinery. Geographically, while the system is designed for nationwide use, initial testing and evaluation will be restricted to a simulated environment and a localized small sample group of farmers and operators to test core functionalities including booking flows, real-time tracking accuracy, and M-Pesa payment processing.

## 1.8 Limitation of the Study
The study anticipates certain limitations. Foremost is the reliance on continuous internet connectivity and GPS availability. In deeply rural areas of Kenya, network coverage can fluctuate, which may impact the real-time tracking features and the immediacy of push notifications. Secondly, the study's field evaluation is limited by time and financial constraints, meaning long-term economic impact assessments on crop yields will fall outside the immediate scope, focusing instead on immediate system usability and booking efficiency.

## 1.9 Definition of Key Terms
- **TaaS (Tractor-as-a-Service):** An innovative business model where farmers access and pay for tractor services on-demand without bearing the capital costs of owning the machinery.
- **Digital Platform:** A software-based online infrastructure that facilitates direct interactions and transactions between two or more distinct but interdependent groups of users (e.g., farmers and operators).
- **WebSockets:** A computer communications protocol providing full-duplex communication channels over a single TCP connection, utilized in this study for live GPS tracking.
- **M-Pesa Daraja API:** The application programming interface provided by Safaricom that allows developers to integrate mobile money payments directly into their software applications.
- **Smallholder Farmer:** Farmers operating on small plots of land (typically less than 2 hectares) who rely heavily on family labor and traditional farming methods, but who are the primary producers in the agricultural sector.


# CHAPTER TWO: LITERATURE REVIEW

## 2.1 Introduction
This chapter provides a critical review of existing literature concerning mechanized farming, the pervasive challenges of tractor accessibility in developing nations, and the theoretical underpinnings of digital platform-mediated service delivery. It evaluates empirical studies to identify gaps in current solutions and establishes the theoretical and conceptual frameworks that anchor this study.

## 2.2 Empirical Review
### 2.2.1 The Impact of Mechanized Farming
Agricultural mechanization is widely recognized as a fundamental catalyst for agricultural growth, poverty alleviation, and rural development. According to Alene and Coulibaly (2009), the introduction of mechanized power, such as tractors, directly increases the efficiency of farm operations by enabling deeper ploughing, timely planting, and the expansion of cultivated land. Their empirical studies across Sub-Saharan Africa demonstrated a strong positive correlation between mechanization adoption and crop yield increases. However, the benefits of mechanization are often disproportionately skewed towards large-scale commercial farmers who possess the financial capacity to purchase and maintain heavy machinery.

### 2.2.2 Challenges in Tractor Accessibility for Smallholder Farmers
Despite the clear benefits, tractor accessibility remains a severe challenge for the majority of smallholder farmers. The Kenya National Bureau of Statistics (KNBS, 2020) highlighted that the high capital cost of purchasing tractors restricts ownership to a wealthy minority, cooperative societies, or corporate farming entities. Consequently, smallholder farmers—who manage the majority of arable land—are forced to rely on a highly fragmented local rental market. This market is characterized by informal networks, severe information asymmetry, and geographic mismatches. Farmers often do not know where available tractors are located, while tractor owners lack visibility into aggregated demand, leading to the paradoxical situation of idle machinery amidst high demand.

### 2.2.3 The Rise of the Digital Platform Economy in Agriculture
The advent of the digital platform economy—often termed the "Uberization" of services—has revolutionized traditional industries by connecting supply and demand through mobile technology, GPS matching, and digital payments (Laudon & Laudon, 2020). Replicating this model in agriculture introduces the concept of "Tractor-as-a-Service" (TaaS). Wang and Li (2021) suggest that TaaS can drastically reshape rural economies by transforming heavy capital expenditures (CapEx) into affordable, variable operational costs (OpEx) for farmers. Early implementations of digital agricultural platforms, such as Hello Tractor in Nigeria, have demonstrated the viability of using telematics and mobile booking to improve machinery utilization. 

However, existing empirical studies also highlight significant challenges with these early platforms, including poor user interfaces that alienate traditional farmers, a lack of deep integration with localized mobile money ecosystems, and insufficient real-time tracking capabilities that leave farmers uncertain about service delivery times.

## 2.3 Theoretical Review
This study is anchored on two primary theoretical frameworks:

### 2.3.1 The Platform Economy Theory
The Platform Economy Theory explains how digital frameworks reduce transaction costs, resolve supply-demand mismatches, and foster trust by creating multi-sided markets. In traditional markets, the transaction costs of finding a tractor, negotiating a price, and ensuring payment are prohibitively high. The platform economy model posits that a centralized digital intermediary can internalize these costs, providing a standardized protocol for engagement. By leveraging network effects—where the platform becomes more valuable to farmers as more operators join, and vice versa—the system achieves efficient resource allocation that traditional fragmented markets cannot.

### 2.3.2 The Technology Acceptance Model (TAM)
The Technology Acceptance Model (TAM), originally proposed by Davis (1989), is utilized to understand the factors influencing the adoption of new technologies by users. TAM asserts that "Perceived Ease of Use" and "Perceived Usefulness" are the primary determinants of behavioral intention to use a system. Given that the target demographic includes rural farmers who may have varying levels of digital literacy, the TAM framework guides the design philosophy of the LimaLink mobile application. The system must be intuitively designed (easy to use) while clearly demonstrating its value in solving the immediate problem of tractor access (useful), thereby ensuring high adoption rates.

## 2.4 Conceptual Framework
The conceptual framework visualizes the structural relationship between the independent, dependent, and mediating variables under study.

- **Independent Variables:** 
  - Real-time GPS tracking capabilities.
  - Digital Payment Integration (M-Pesa).
  - Operator Verification and Rating System.
  - User Interface Design.

- **Dependent Variables:** 
  - Service Efficiency (reduced booking latency).
  - Tractor Utilization Rates.
  - User Satisfaction (Farmers and Operators).

- **Mediating Variables:** 
  - Internet connectivity and network stability.
  - Digital literacy of the end-users.

**Operationalization:** 
The system connects three primary entities: the Farmer, the Tractor Operator, and the System Administrator. The Farmer utilizes the mobile app to initiate a service request based on their current location. The Node.js backend processes this request, utilizing PostgreSQL for data integrity and Socket.io to broadcast the request to nearby available Operators. Upon job acceptance, the system establishes a live GPS tracking session, allowing the farmer to monitor the tractor's approach. Upon completion, a digital payment handshake is initiated via the M-Pesa API, ensuring funds are securely transferred to the operator's digital wallet. The Administrator oversees all transactions via the React web dashboard, utilizing analytics to ensure platform health and resolve disputes.

## 2.5 Summary and Research Gap
Existing literature establishes a clear, undeniable need for improved access to mechanized farming services among smallholder farmers. While theoretical models support the transition to "Tractor-as-a-Service," and early commercial attempts have validated the concept, a critical research gap remains. There is a lack of highly localized, fully integrated digital solutions that cater specifically to the Kenyan financial ecosystem (deep M-Pesa integration) while offering true real-time WebSocket-based tracking and a robust administrative oversight mechanism. This study seeks to fill that gap by developing and evaluating a prototype that seamlessly marries these advanced technologies into a unified, user-centric platform.

---

# CHAPTER THREE: RESEARCH METHODOLOGY

## 3.1 Introduction
This chapter outlines the methodology and procedures that will be utilized in conducting the study and developing the LimaLink platform. It details the research philosophy, design, study area, target population, sampling techniques, data collection instruments, and the specific software engineering methodology employed to construct the technological artifact.

## 3.2 Research Philosophy
The study adopts a **Pragmatism** research philosophy. Pragmatism focuses on practical outcomes, real-world problem-solving, and the application of knowledge to create tangible solutions. Rather than engaging in purely abstract theoretical debates, this philosophy aligns perfectly with the field of Computer Science and Software Engineering, where the ultimate goal is the creation of a functional, efficient software artifact that directly addresses the identified logistical challenges in agricultural mechanization.

## 3.3 Research Design
The research will utilize an **Applied Research Design**. Applied research is directed towards solving practical, specific problems—in this case, the inefficiency in tractor scheduling and allocation. The design involves the actual construction of the software system followed by an empirical evaluation of its performance and usability. It bridges the gap between theoretical computer science concepts (like real-time data streaming and relational database optimization) and their practical application in a rural economic context.

## 3.4 Study Area
The software artifact will be developed, hosted, and initially tested within the computing environments at Laikipia University. However, to evaluate the system's effectiveness, the study area for field testing will simulate a rural agricultural setting characterized by typical smallholder farming activities. The choice of simulating a rural environment ensures that the system's reliance on GPS accuracy and mobile network latency is tested under realistic, non-urban conditions.

## 3.5 Target Population
The target population for the eventual deployment of this system comprises all smallholder farmers and private agricultural machinery owners in Kenya. For the purpose of evaluating the prototype developed in this study, the accessible population consists of individuals with access to smartphones who are familiar with basic agricultural operations and mobile money transactions.

## 3.6 Sampling Design
Due to time and resource constraints, the study will employ **Purposive Sampling** to select a localized group of participants for the prototype evaluation phase. A sample size of 15 participants—comprising 10 individuals acting as farmers and 5 individuals acting as tractor operators—will be selected. These participants must own an Android smartphone, have basic digital literacy, and have an active M-Pesa account to participate in the simulated booking and payment testing. While small, this sample size is sufficient for identifying critical usability flaws and validating the core technical functionalities of the prototype.

## 3.7 Data Collection Instruments
Data will be collected using two primary methods, addressing both the technical performance of the system and its usability:

### 3.7.1 System Logs (Quantitative)
The backend PostgreSQL database and Node.js server will be configured to automatically record critical performance metrics during the testing phase. This quantitative data will include:
- **Booking Latency:** The time elapsed between a farmer submitting a request and an operator accepting it.
- **Transaction Success Rate:** The percentage of M-Pesa API payment requests that execute successfully without timeouts or errors.
- **Tracking Uptime:** The reliability and frequency of GPS coordinate updates transmitted via WebSockets during an active job.

### 3.7.2 System Usability Scale (SUS) Questionnaires (Quantitative & Qualitative)
To evaluate the user experience, participants will complete a standardized System Usability Scale (SUS) questionnaire after interacting with the mobile application. The SUS provides a reliable tool for measuring usability through a 10-item questionnaire with five response options (from Strongly Agree to Strongly Disagree). Additionally, the questionnaire will include open-ended sections allowing participants to provide qualitative feedback regarding the app's interface, perceived usefulness, and areas for improvement.

## 3.8 Data Analysis and Presentation
Quantitative data extracted from system logs and the SUS questionnaires will be analyzed using statistical software (such as SPSS or Excel). Descriptive statistics, including frequencies, means, and standard deviations, will be generated to summarize system performance and overall usability scores. The findings will be presented using comprehensive tables, bar charts, and line graphs to ensure clear visual communication of the results. Qualitative data from the open-ended feedback will be analyzed thematically, categorizing responses into core themes such as "Interface Challenges," "Trust in Digital Payments," and "GPS Accuracy."

## 3.9 System Development Methodology
The technological construction of the LimaLink platform will strictly adhere to the **Agile Software Development Methodology**, specifically utilizing the Scrum framework. The Agile methodology is chosen due to its iterative, incremental nature, which is highly suited for projects involving complex integrations (like third-party payment gateways) where requirements and technical hurdles may evolve during development.

The development will be divided into specific "Sprints":
- **Sprint 1: Requirements Gathering & Database Design:** Defining the exact data structures in PostgreSQL, establishing foreign key relationships for users, tractors, and bookings, and designing the RESTful API endpoints.
- **Sprint 2: Backend & Payment Integration:** Developing the Node.js/Express server, implementing JWT-based authentication, and securely integrating the Safaricom M-Pesa Daraja API for STK Push payments.
- **Sprint 3: Real-Time Communication:** Setting up Socket.io for bidirectional communication, enabling instant job notifications, and establishing the "rooms" architecture for live GPS location broadcasting.
- **Sprint 4: Mobile App Development:** Building the cross-platform Flutter application for both Farmers and Operators, integrating Google Maps for visualization, and connecting to the backend APIs.
- **Sprint 5: Admin Dashboard Development:** Developing the React-based web dashboard, incorporating Tailwind CSS for styling, and Leaflet maps for global fleet monitoring.
- **Sprint 6: System Integration & Testing:** Conducting end-to-end testing, simulating concurrent bookings, and resolving bugs before the final evaluation phase.

---

# REFERENCES
1. Alene, A. D., & Coulibaly, O. (2009). The impact of agricultural research on productivity and poverty in sub-Saharan Africa. *Food Policy*, 34(2), 198-209.
2. Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. *MIS Quarterly*, 13(3), 319-340.
3. Kenya National Bureau of Statistics (KNBS). (2020). *Economic Survey 2020*. Nairobi: KNBS.
4. Laudon, K. C., & Laudon, J. P. (2020). *Management Information Systems: Managing the Digital Firm* (16th ed.). Pearson.
5. Wang, Y., & Li, J. (2021). The Platform Economy in Agriculture: Opportunities and Challenges. *Journal of Rural Studies*, 82, 12-21.

---

# APPENDICES

## Appendix I: Proposed Research Schedule (Work Plan)
| Activity | Month 1 | Month 2 | Month 3 | Month 4 | Month 5 |
|----------|---------|---------|---------|---------|---------|
| Concept Formulation & Proposal Writing | X | | | | |
| System Requirements Analysis & DB Design | | X | | | |
| Backend API & M-Pesa Integration Development | | X | X | | |
| Real-Time Sockets & Mobile App Development | | | X | X | |
| Admin Web Dashboard Development | | | | X | |
| System Testing, Evaluation & Final Report Writing | | | | | X |

## Appendix II: Estimated Budget
| Item / Software / Hardware / Logistics | Estimated Cost (KES) |
|----------------------------------------|----------------------|
| Cloud Hosting (VPS) & Domain Registration | 6,500 |
| Internet Data & Connectivity Subscriptions | 5,000 |
| Safaricom M-Pesa API Integration Costs | 2,000 |
| Transport / Logistics for Field Testing | 4,000 |
| Printing & Binding of Proposal/Reports | 3,500 |
| Miscellaneous / Contingency Expenses | 4,000 |
| **Total Estimated Budget** | **25,000** |
