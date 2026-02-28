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

---

## DEDICATION
This research is dedicated to the smallholder farmers in Kenya whose hard work sustains our nation. It is also dedicated to my family and friends for their continuous support and encouragement throughout my academic journey.

---

## ACKNOWLEDGEMENT
I wish to express my sincere gratitude to my supervisor for the invaluable guidance and constructive feedback during the conceptualization of this proposal. Special thanks to the Department of Computing and Informatics at Laikipia University for providing an enabling environment for research.

---

## ABSTRACT
Mechanized farming is essential for increasing agricultural productivity. However, smallholder farmers face significant hurdles in accessing farm-ploughing tractors due to high costs, uneven distribution, and poor scheduling. Similarly, tractor owners suffer from equipment underutilization. This project proposes the development of an "Uber-like" digital platform for farm-ploughing tractors. The system will connect farmers to available tractor operators in real-time. It will be implemented using a Mobile Application (Flutter) for end-users and a Web Dashboard (React + Tailwind CSS) for administrative oversight. The backend will be powered by Node.js, Express, and PostgreSQL, featuring WebSockets (Socket.io) for live tractor location tracking and Safaricom's M-Pesa Daraja API for seamless digital payments. By bridging the gap between demand and supply, this platform aims to optimize tractor utilization, reduce waiting times, and improve overall crop yields.

---

# CHAPTER ONE: INTRODUCTION

## 1.1 Background to the Study
Mechanized farming plays a pivotal role in augmenting agricultural output and ensuring food security (Alene & Coulibaly, 2009). The introduction of machinery like tractors significantly reduces manual labor and speeds up land preparation, which is crucial for maximizing seasonal planting windows. Despite its importance, access to mechanized farming services in many rural areas of Kenya remains exceptionally low. Smallholder farmers often struggle to locate and hire tractors when they need them the most (Kenya National Bureau of Statistics [KNBS], 2020). Conversely, owners of agricultural machinery frequently complain about their equipment sitting idle due to poor visibility and inefficient scheduling mechanisms. The traditional, informal approach of securing tractor services relies heavily on word-of-mouth or middle-men, which is not only inefficient but also prone to miscommunication, lack of accountability, and inflated pricing. In an era dominated by digital transformation, applying the platform-economy model—popularized by ride-hailing services like Uber—presents a viable solution to the agricultural sector's logistical challenges.

## 1.2 Problem Statement
Despite the proven benefits of mechanized land preparation, small and medium-scale farmers in rural Kenya experience severe delays and high costs when attempting to hire farm-ploughing tractors. The reliance on manual scheduling and informal agreements leads to unpredictable service delivery, lack of transparent pricing, and difficulty in processing payments securely. Simultaneously, tractor owners suffer from significant underutilization of their expensive machinery due to an inability to efficiently locate nearby farmers requiring their services. The absence of a centralized, real-time matching system results in lost time, reduced crop yields due to missed planting seasons, and diminished profitability for both farmers and tractor operators.

## 1.3 Purpose of the Study
The primary purpose of this project is to design, develop, and evaluate a prototype digital platform that facilitates the real-time booking, sharing, and optimal utilization of farm-ploughing tractors. 

## 1.4 Specific Objectives
The project aims to achieve the following specific objectives:
1. To design and develop a mobile application allowing farmers to view nearby tractors, book ploughing services, and process digital payments via M-Pesa.
2. To build an operator module within the application for tractor owners to accept job requests, view schedules, and provide real-time GPS location updates.
3. To develop a web-based dashboard (React + Tailwind CSS) for administrators to monitor platform metrics, verify operators, manage disputes, and analyze demand heatmaps.
4. To implement a secure and robust backend system (Node.js + PostgreSQL) that efficiently handles user authentication, booking logic, and Socket.io for live tracking.

## 1.5 Research Questions
1. How can a digital platform optimize the scheduling and allocation of tractor services among smallholder farmers?
2. What are the key technical requirements for implementing real-time GPS tracking and M-Pesa digital payments in an agricultural service app?
3. To what extent will the proposed system improve the operational efficiency and revenue of tractor owners?

## 1.6 Justification of the Study
The realization of this platform will have a direct positive impact on Kenya’s agricultural value chain. For the farmers, it will eliminate the uncertainty and delays associated with finding equipment, directly translating to timely planting and better yields. For the tractor owners, it will provide a steady stream of verifiable customers, significantly increasing return on investment. Academically, this study will demonstrate the successful application of modern software engineering practices—specifically real-time tracking (WebSockets), secure APIs, and relational database management—to an underserved traditional sector.

---

# CHAPTER TWO: LITERATURE REVIEW

## 2.1 Introduction
This chapter reviews existing literature concerning mechanized farming, the challenges of tractor accessibility, and the rise of digital platform-mediated service delivery in agriculture.

## 2.2 Mechanized Farming and its Challenges
Mechanization is widely recognized as a catalyst for agricultural growth. According to Alene & Coulibaly (2009), mechanization increases the efficiency of farm operations. However, the KNBS (2020) highlights that the high capital cost of purchasing tractors restricts ownership to a wealthy minority or corporate entities, leaving the vast majority of smallholder farmers dependent on a highly fragmented local rental market. 

## 2.3 The Digital Platform Economy (Uber Model)
The ride-sharing model relies on connecting supply and demand through mobile technology, utilizing GPS matching and digital payments (Laudon & Laudon, 2020). Replicating this model in agriculture, specifically for tractor services, introduces the concept of "Tractor-as-a-Service" (TaaS). Wang & Li (2021) suggest that TaaS can drastically reshape rural economies by transforming heavy capital expenditures into affordable, variable operational costs for farmers. 

## 2.4 Existing Systems and Gap Analysis
While platforms like "Hello Tractor" have attempted to introduce telematics to machinery owners, there remains a gap in providing a localized, fully integrated solution that caters to the specific financial ecosystems of Kenyan farmers—specifically the deep integration with mobile money (M-Pesa Daraja API) and a lightweight, open-source architecture that local cooperatives can easily adopt and manage.

## 2.5 Conceptual Framework
The proposed system operates on a framework connecting three primary entities: the Farmer, the Tractor Operator, and the System Administrator. The Farmer utilizes the mobile app to initiate a service request based on location. The Node.js backend processes this request, utilizing PostgreSQL for data integrity and Socket.io to broadcast the request to nearby available Operators. Upon acceptance, the system establishes a live GPS tracking session and initiates a digital payment handshake via M-Pesa. The Administrator oversees these transactions via the React web dashboard, utilizing analytics to ensure platform health.

---

# CHAPTER THREE: METHODOLOGY

## 3.1 Introduction
This chapter outlines the proposed methodology for the development of the Uber-like tractor platform, including data collection, system design, and the software development lifecycle.

## 3.2 Research Design
The study will adopt an Applied Research design, focusing on solving the practical problem of tractor accessibility through the creation of a software artifact. 

## 3.3 System Development Methodology
The project will utilize the **Agile Software Development Methodology** (Scrum). This iterative approach allows for continuous refinement of features such as live tracking and payment integrations based on testing feedback.
- **Phase 1: Requirements & Planning** (Defining database schemas in PostgreSQL, identifying API endpoints).
- **Phase 2: Backend Development** (Building the REST API with Node.js/Express, setting up Socket.io for tracking, and M-Pesa API integration).
- **Phase 3: Frontend & Mobile Development** (Creating the React Admin Dashboard and Flutter Mobile App).
- **Phase 4: Integration & Testing** (End-to-end testing of the booking flow and automated payment verification).

## 3.4 Method of Data Collection & Analysis
For evaluating the completed prototype:
- **Primary Data:** Structured questionnaires administered to a sample group of farmers and tractor operators to assess system usability (measured via System Usability Scale - SUS).
- **Secondary Data:** System-generated logs from PostgreSQL detailing transaction completion rates, average booking latency, and system uptime.
Quantitative data will be analyzed using statistical software to generate descriptive statistics, while qualitative feedback from user interviews will undergo thematic analysis.

---

# REFERENCES
1. Alene, A. D., & Coulibaly, O. (2009). The impact of agricultural research on productivity and poverty in sub-Saharan Africa. *Food Policy*, 34(2), 198-209.
2. Kenya National Bureau of Statistics (KNBS). (2020). *Economic Survey 2020*. Nairobi: KNBS.
3. Laudon, K. C., & Laudon, J. P. (2020). *Management Information Systems: Managing the Digital Firm* (16th ed.). Pearson.
4. Wang, Y., & Li, J. (2021). The Platform Economy in Agriculture: Opportunities and Challenges. *Journal of Rural Studies*, 82, 12-21.

---

# APPENDICES

## Appendix I: Proposed Research Schedule (Work Plan)
| Activity | Month 1 | Month 2 | Month 3 | Month 4 |
|----------|---------|---------|---------|---------|
| Concept & Proposal Writing | X | | | |
| System Requirements & DB Design | | X | | |
| Backend API & M-Pesa Integration | | X | X | |
| Mobile App & Web Dashboard Dev | | | X | X |
| System Testing & Evaluation | | | | X |
| Final Report Compilation | | | | X |

## Appendix II: Estimated Budget
| Item / Software / Hardware | Estimated Cost (KES) |
|----------------------------|----------------------|
| Internet Data & Hosting (VPS/Cloud) | 5,000 |
| Printing & Binding of Proposal/Reports | 3,000 |
| Transport / Logistics for Field Testing | 4,000 |
| Miscellaneous Expenses | 3,000 |
| **Total Estimated Budget** | **15,000** |
