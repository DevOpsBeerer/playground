# DevOpsBeerer 🍺

A playground and comprehensive documentation for **OIDC** and **OAuth2** standards, designed to help developers understand authentication and authorization flows through hands-on experience.

**DevOpsBeerer** combines DevOps, Bearer tokens, and beer in a fun, educational environment where you can experiment with modern authentication patterns in a realistic scenario.

## 🎯 What is DevOpsBeerer?

DevOpsBeerer is an educational platform that provides:

- **Interactive Playground**: A complete SSO-enabled environment running on Keycloak
- **Comprehensive Documentation**: Real-world scenarios covering Enterprise SSO, API authentication, and more
- **Practical Examples**: Working applications demonstrating OIDC/OAuth2 flows
- **On-Premise Deployment**: Run everything locally using Kubernetes (K3s)

## 🏗️ Architecture Overview

The playground consists of several components working together:

### Applications

- **Beer API**: RESTful API for managing beer inventory (CRUD operations)
- **Frontoffice**: Public-facing web application for beer browsing
- **Backoffice**: Administrative interface for beer management (comming soon)
- **Future Extensions**: Additional scenarios and integrations

### Infrastructure

- **Keycloak**: Identity and Access Management (IAM) server
- **K3s**: Lightweight Kubernetes distribution
- **Nginx Ingress**: HTTP/HTTPS routing and load balancing
- **Cert-Manager**: Automatic TLS certificate management

### Authentication Flows Demonstrated

- Authorization Code Flow
- Client Credentials Flow (comming soon)
- Device Authorization Flow  (comming soon)
- Token introspection and validation (comming soon)

## 🚀 Quick Start

### Prerequisites

- Linux system (Ubuntu/Debian/CentOS/RHEL)
- Root or sudo access
- Minimum 2GB RAM, 2 CPU cores
- Internet connection for downloading components

### Installation

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd devopsbeerer-playground
   ```

2. **Install K3s and base infrastructure**

   ```bash
   chmod +x *.sh
   sudo ./install-k3s.sh
   ```

3. **Initialize Kubernetes components**

   ```bash
   sudo ./init-k3s.sh
   ```

4. **Deploy the applications**

   ```bash
   sudo ./init-app.sh
   ```

### Verification

After installation, verify your deployment:

```bash
# Check if all pods are running
sudo k3s kubectl get pods --all-namespaces

# Check ingress endpoints
sudo k3s kubectl get ingress --all-namespaces
```

### Access the Playground

Once deployed, you can access:

- **Keycloak Admin Console**: `https://sso.devopsbeerer.local/admin`
- **Beer API**: `https://api.devopsbeerer.local`
- **Frontoffice**: `https://devopsbeerer.local`
- **Backoffice**: `https://admin.devopsbeerer.local`

*Note: Add these domains to your `/etc/hosts` file pointing to your server's IP address.*

## 📁 Project Structure

```
devopsbeerer-playground/
├── install-k3s.sh              # K3s installation script
├── init-k3s.sh                 # Infrastructure initialization
├── init-app.sh                 # Application deployment
├── deployments/                # Kubernetes manifests for applications
│   ├── api/                    # Beer API deployment files
│   ├── frontoffice/            # Public web app deployment
│   └── backoffice/             # Admin interface deployment
├── k3s/                        # Infrastructure configuration
│   ├── config.yaml             # K3s server configuration
│   ├── ingress-controller.yaml # Nginx ingress settings
│   ├── cert-manager.yaml       # Certificate issuer configuration
│   └── keycloak.yaml           # Keycloak Helm values
└── docs/                       # Documentation and tutorials
    ├── scenarios/              # Different OIDC/OAuth2 scenarios
    ├── enterprise/             # Enterprise integration guides
    └── api/                    # API documentation
```

## 📚 Learning Scenarios

### Basic Scenarios

1. **User Authentication**: Login flow with Authorization Code
2. **API Access**: Securing REST APIs with Bearer tokens
3. **Single Sign-On**: Cross-application authentication
4. **Token Management**: Refresh tokens and expiration handling

### Enterprise Scenarios

1. **LDAP Integration**: Connect with existing directory services
2. **Multi-tenant SSO**: Separate realms for different organizations
3. **Role-Based Access Control**: Fine-grained permissions
4. **Identity Federation**: SAML and social login integration

### Advanced Scenarios

1. **Microservices Authentication**: Service-to-service communication
2. **Mobile App Integration**: PKCE flow implementation
3. **API Gateway Integration**: Token validation and routing
4. **Audit and Compliance**: Logging and monitoring authentication events

## 🔧 Configuration

### Customizing Keycloak

Default Keycloak configuration includes:

- Admin user: `admin` / `admin123`
- Demo realm: `devopsbeerer`
- Pre-configured clients for each application

### Modifying Applications

Each application in `deployments/` can be customized:

- Environment variables for OIDC endpoints
- Resource server configurations
- CORS and security policies

### Network Configuration

The setup uses `.local` domains by default. For production or external access:

1. Update ingress hostnames in deployment files
2. Configure proper DNS or load balancer
3. Update Keycloak redirect URIs accordingly

## 🐛 Troubleshooting

### Common Issues

**K3s installation fails**

```bash
# Check system requirements and firewall
sudo systemctl status k3s
sudo journalctl -u k3s
```

**Pods stuck in Pending state**

```bash
# Check node resources and pod scheduling
sudo k3s kubectl describe pod <pod-name> -n <namespace>
sudo k3s kubectl get nodes -o wide
```

**SSL/TLS certificate issues**

```bash
# Check cert-manager logs
sudo k3s kubectl logs -n cert-manager deployment/cert-manager
sudo k3s kubectl get certificates --all-namespaces
```

**Keycloak not accessible**

```bash
# Verify ingress and service
sudo k3s kubectl get ingress -n sso
sudo k3s kubectl get svc -n sso
```

### Reset Environment

To completely reset the playground:

```bash
# Uninstall K3s and all components
sudo /usr/local/bin/k3s-uninstall.sh

# Clean up any remaining files
sudo rm -rf /etc/rancher/k3s/
sudo rm -rf /var/lib/rancher/k3s/
```

## 🤝 Contributing

We welcome contributions! Whether it's:

- New authentication scenarios
- Documentation improvements
- Bug fixes and optimizations
- Additional application examples

Please submit issues and pull requests to help improve the playground.

## 📖 Documentation

Detailed documentation is available in the `/docs` directory:

- **Getting Started Guide**: Step-by-step tutorials
- **OIDC/OAuth2 Fundamentals**: Core concepts explained
- **Enterprise Integration**: Real-world implementation patterns
- **API Reference**: Complete endpoint documentation
- **Troubleshooting Guide**: Common issues and solutions

## 🌐 Online vs On-Premise

- **Online Playground**: Available at `https://playground.devopsbeerer.io` (coming soon)
- **On-Premise**: Use this repository to run locally with full control

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎉 Have Fun Learning

DevOpsBeerer makes learning OIDC and OAuth2 enjoyable. Grab a beer (virtual or real) and start exploring modern authentication patterns!

---

*For questions, issues, or contributions, please visit our GitHub repository or join our community discussions.*
