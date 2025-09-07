# Case Study: Implementing A/B Testing with Nginx and Docker

## Case Context

**Client**: FastShop, a growing e-commerce startup that wants to improve its user experience.

**Problem**: The UX team has designed a new version of the homepage that they believe will increase conversions, but the CEO wants evidence before a full rollout. They need a way to show different versions of the page to users and measure performance.

**Objective**: Implement an A/B testing system that can serve two different versions of the web application, assign users to each version via specific routes, and facilitate the collection of conversion metrics.

**Constraints**:
- Limited budget, with a preference for container-based solutions.
- Cannot substantially modify the existing application code.
- Need a solution that can be implemented quickly.

## Proposed Solution

In this case study, we will implement an Nginx-based proxy system that serves different versions of a web application through specific URLs. This solution facilitates A/B testing and allows the development team to directly access each version.

## Project Structure

```
proxy-lab/
├── app/
│   ├── app_a.py
│   ├── app_b.py
│   ├── Dockerfile.a
│   └── Dockerfile.b
└── nginx/
    ├── nginx.conf
    └── Dockerfile
```

## Step-by-Step Guide

### Step 1: Prepare the Work Environment

First, let's create the base project structure:

```bash
# Create the main project directory
mkdir proxy-lab

# Enter the project directory
cd proxy-lab

# Create the directory for the applications
mkdir app
```

### Step 2: Create the Flask Applications (Simulating Website Versions)

To simulate the two different versions of FastShop's homepage, we will create two simple Flask applications.

```bash
# Enter the applications directory
cd app
```

#### Application A (Original Version)

```bash
# Create the file for application A
vi app_a.py
```

Add the following content:

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>FastShop - Your Online Store</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
            .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 5px; }
            .header { color: #2c3e50; text-align: center; }
            .button { background-color: #3498db; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1 class="header">Welcome to FastShop - Version A (Original)</h1>
            <p>Discover our high-quality products at incredible prices.</p>
            <button class="button">View Offers</button>
        </div>
    </body>
    </html>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
```

Now, create the Dockerfile for application A:

```bash
# Create the Dockerfile for application A
vi Dockerfile.a
```

Add the following content:

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY app_a.py .
RUN pip install flask
CMD ["python", "app_a.py"]
```

#### Application B (New Version Proposed by UX)

Next, create the file for application B, which represents the new design proposed by the UX team:

```bash
# Create the file for application B
vi app_b.py
```

Add the following content:

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>FastShop - A Renewed Shopping Experience</title>
        <style>
            body { font-family: 'Roboto', sans-serif; margin: 0; padding: 0; background-color: #ecf0f1; }
            .hero { background-color: #2980b9; color: white; padding: 40px; text-align: center; }
            .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
            .cta-button { background-color: #e74c3c; color: white; padding: 15px 30px; border: none; border-radius: 30px; 
                          font-size: 18px; margin-top: 20px; cursor: pointer; }
            .features { display: flex; justify-content: space-between; margin-top: 30px; text-align: center; }
            .feature { flex: 1; padding: 20px; }
        </style>
    </head>
    <body>
        <div class="hero">
            <h1>Discover the New FastShop Experience - Version B</h1>
            <p>Shop faster, find better deals, and enjoy a renewed experience.</p>
            <button class="cta-button">EXPLORE EXCLUSIVE OFFERS</button>
        </div>
        <div class="container">
            <div class="features">
                <div class="feature">
                    <h3>Free Shipping</h3>
                    <p>On all orders over €50</p>
                </div>
                <div class="feature">
                    <h3>Exclusive Discounts</h3>
                    <p>Up to 70% off on selected products</p>
                </div>
                <div class="feature">
                    <h3>24/7 Support</h3>
                    <p>Support available every day</p>
                </div>
            </div>
        </div>
    </body>
    </html>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
```

Create the Dockerfile for application B:

```bash
# Create the Dockerfile for application B
vi Dockerfile.b
```

Add the following content:

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY app_b.py .
RUN pip install flask
CMD ["python", "app_b.py"]
```

### Step 3: Build the Docker Images for the Applications

```bash
# Return to the main project directory
cd ..

# Build the Docker image for version A
# The dot at the end indicates the build context is the current directory
docker build -f app/Dockerfile.a -t myapp:version-a app/

# Build the Docker image for version B
docker build -f app/Dockerfile.b -t myapp:version-b app/
```

### Step 4: Configure Nginx as a Proxy for A/B Testing

In this step, we will configure Nginx as a reverse proxy that will direct traffic to each application version based on specific routes.

```bash
# Create the directory for Nginx files
mkdir nginx

# Enter the Nginx directory
cd nginx
```

Create the Nginx configuration file:

```bash
# Create the Nginx configuration file
vi nginx.conf
```

Add the following content (optimized configuration):

```nginx
events {
    worker_connections 1024;
}

http {
    # Basic settings
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    # Server definitions
    server {
        listen       80;
        server_name  localhost;

        # Route for version A
        location /version-a/ {
            proxy_pass http://app_a/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Route for version B
        location /version-b/ {
            proxy_pass http://app_b/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Root location redirects to version-a by default
        location = / {
            return 302 /version-a/;
        }
    }
}
```

Create the Dockerfile for Nginx:

```bash
# Create the Dockerfile for Nginx
vi Dockerfile
```

Add the following content:

```dockerfile
FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
```

### Step 5: Build the Nginx Image

```bash
# Return to the main project directory
cd ..

# Build the Docker image for Nginx
# This creates an image from the Dockerfile in the nginx/ directory
docker build -t mynginx -f nginx/Dockerfile nginx
```

### Step 6: Create the Docker Network and Run the Containers

```bash
# Create a Docker network for inter-container communication
# This allows containers to communicate using names instead of IPs
docker network create my-network

# Run the container for application A
# --name: assigns a name to the container
# --network: connects the container to the specified network
# --network-alias: allows other containers on the same network to resolve this container by its name
docker run -d --name app_a --network my-network --network-alias app_a myapp:version-a

# Run the container for application B
docker run -d --name app_b --network my-network --network-alias app_b myapp:version-b

# Run the Nginx container
# -p 80:80: maps port 80 on the host to port 80 in the container
docker run -d --name nginx-proxy --network my-network -p 80:80 mynginx
```

### Step 7: Verify the Setup

```bash
# Check that all containers are running
docker ps

# Access version A directly
curl http://localhost/version-a/

# Access version B directly
curl http://localhost/version-b/

# Access the root URL (should redirect to version-a)
curl -L http://localhost/
```

You can also test by opening these URLs in your browser:
- `http://localhost/version-a/` to see the original version
- `http://localhost/version-b/` to see the new version
- `http://localhost/` will automatically redirect you to version A

### Step 8: Common Troubleshooting

If you encounter any issues, here are some steps to debug them:

```bash
# View container logs
docker logs app_a
docker logs app_b
docker logs nginx-proxy

# Shell into the Nginx container for testing
docker exec -it nginx-proxy /bin/sh

# Inside the Nginx container, verify connectivity to the applications
ping app_a
ping app_b
curl http://app_a
curl http://app_b

# If needed, restart the entire environment
docker stop app_a app_b nginx-proxy
docker rm app_a app_b nginx-proxy
docker network rm my-network
docker network create my-network
docker run -d --name app_a --network my-network --network-alias app_a myapp:version-a
docker run -d --name app_b --network my-network --network-alias app_b myapp:version-b
docker run -d --name nginx-proxy --network my-network -p 80:80 mynginx
```

## Results and Analysis

Implementing this proxy system allowed FastShop to conduct effective A/B tests with the following advantages:

1.  **Direct Access to Versions**: Users and the development team can directly access each version via specific URLs.
2.  **Transparency for Testing**: The automatic redirection allows new users to be directed to version A by default.
3.  **Simple Implementation**: The route-based configuration is easy to understand and maintain.
4.  **Scalability**: The container-based design allows for horizontal scaling based on demand.

## Critical Analysis Questions

1.  **Architecture and Design**:
    -   What advantages does the microservices architecture used here offer compared to a monolithic application?
    -   How would you adapt this solution to implement load balancing in addition to A/B testing?
    -   What security considerations should be taken into account when deploying this solution to production?

2.  **Technical Implementation**:
    -   How would you modify the configuration to implement a random traffic split (e.g., 70/30) between versions A and B?
    -   What strategy would you implement to collect conversion metrics from each version?
    -   How would you adapt this solution to handle more than two simultaneous versions?

3.  **Operations and Maintenance**:
    -   What backup and recovery strategy would you implement for this system?
    -   How would you perform application updates with zero downtime?
    -   What monitoring metrics would be critical to ensure the proxy is functioning correctly?

4.  **Business Considerations**:
    -   What specific metrics would you recommend to FastShop for evaluating the success of each version?
    -   How would you integrate this system with analytics tools like Google Analytics?
    -   What ethical considerations should be taken into account when conducting A/B tests with real users?

## Extension Activity

Modify the proposed solution to:
1.  Implement a percentage-based traffic distribution system (60% to version A, 40% to version B).
2.  Add custom HTTP headers that allow analytics systems to identify which version each user is seeing.
3.  Design a mechanism to force a specific version for testing purposes (e.g., using a query parameter).

---

## Additional Notes

### Alternative: Cookie-Based Implementation

An alternative to the route-based solution would be to implement a cookie-based system. This would automatically assign users to a version and maintain that assignment on subsequent visits. This implementation is more suitable for authentic A/B tests where the assignment must be transparent to the user.

### Advantages of the Implemented Solution

The route-based solution implemented in this case study has several advantages for an educational setting:
- Greater simplicity and ease of understanding.
- Simpler debugging process.
- Direct access to each version without manipulating cookies or headers.
- Facilitates demonstrating the core concept without additional complexities.
