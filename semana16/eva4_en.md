### **Guided Deployment Manual: Modular WordPress on AWS**

**Welcome, Future Cloud Architect!**

As an AWS specialist with a focus on learning methodologies, I have designed this manual so that you not only execute commands but also understand the *why* behind each decision. Through a practical case study, you will build a robust, secure, and modular solution, developing critical skills for your career.

**Learning Objectives:**

*   Interpret Infrastructure as Code (IaC) templates to derive requirements.
*   Design a secure and efficient network topology in AWS.
*   Implement a multi-stack architecture using AWS CloudFormation.
*   Validate and document a cloud deployment.

---

#### **Case Study: Elena's Portfolio**

**The Client:** Elena is a professional photographer who needs to launch her online portfolio and blog.
**The Challenge:** She needs a solution that is:
1.  **Economical:** She wants to start without fixed costs, taking advantage of the AWS free tier.
2.  **Secure:** Her data and her clients' data must be protected. The database should not be accessible from the internet.
3.  **Reliable:** The site must be available, and the database must be managed to avoid problems.
4.  **Future-Proof Scalability:** The solution should be a solid foundation that can grow if her business takes off.

Your mission is to build this solution for Elena.

**Prerequisites:**
*   An active AWS account.
*   You must have created a **Key Pair** in the EC2 console of your preferred region (e.g., `us-east-1`).

---

### **Phase 1: Analysis (Estimated Time: 20 minutes)**

**Objective:** Understand the solution before building it, translating code into requirements.

**Your Task:** Open the three YAML files (`00-network-stack.yaml`, `01-security-stack.yaml`, `02-application-stack.yaml`) in a text editor. Read them and, based on their content, extract the following requirements.

**1. Functional Requirements (What does the system do?)**
*   
    *   
    *   
    *   
    *   
    *   The website is publicly accessible via HTTP (port 80).

**2. Non-Functional Requirements (How does it do it? - Quality, Security, Cost)**
*   **
    *   **Cost:** 
    *   **Security:**
        *   
        *   
        *   
    *   **Modularity:** 
    *   **Availability:** 

---

### **Phase 2: Design (Estimated Time: 15 minutes)**

**Objective:** Visualize the architecture you have analyzed. A good architect always has a diagram.

**Your Task:** Based on the previous analysis, draw the solution's topology on paper or using a diagramming tool. Your diagram should show: the VPC, subnets (public and private), EC2, RDS, the Internet Gateway, and how the security groups connect.

**Reference Diagram for Self-Assessment:**
