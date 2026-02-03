# 🔒 Security Best Practices

This document outlines security considerations for your Laravel Multi-Site Development Environment.

## ⚠️ DEVELOPMENT ENVIRONMENT NOTICE

**This setup is designed for LOCAL/DEVELOPMENT use only.** It prioritizes developer convenience over production-grade security.

### Key Differences from Production:
- Database credentials stored in `credentials/` directory for easy access
- Credentials mounted as read-only volumes in containers
- MySQL port may be exposed for GUI tools (TablePlus, etc.)
- Simplified authentication and access controls
- Debug information visible in placeholder pages

### 🚫 DO NOT USE THIS SETUP FOR PRODUCTION

For production deployments, use:
- Proper secrets management (AWS Secrets Manager, HashiCorp Vault, etc.)
- Environment variables injected at runtime (not mounted files)
- SSL/TLS certificates
- Restricted network access
- Security hardening (see production security guides)

---

## 🔐 Development Environment Security

### 1. Protect Your Development Server

If running on a remote development server:

If running on a remote development server:

```bash
# Configure firewall
sudo ufw allow 22/tcp    # SSH only
sudo ufw allow 80/tcp    # HTTP for development
sudo ufw enable

# Optional: Expose MySQL for remote GUI tools
# Only do this on trusted networks!
# In docker-compose.yml:
# mysql:
#   ports:
#     - "3306:3306"  # Or "127.0.0.1:3306:3306" for localhost only
```

### 2. Secure Credential Files

The `credentials/` directory contains database passwords:

```bash
# Ensure proper permissions
chmod 700 credentials/
chmod 600 credentials/*.env

# Already in .gitignore - verify:
grep -q "credentials" .gitignore && echo "✓ Protected"
```

### 3. Use Strong Auto-Generated Passwords

The setup script generates secure passwords automatically. If you need to create databases manually:

### 4. Local Development Best Practices

```bash
# Keep credentials directory secure
chmod 700 credentials/

# Don't commit .env files
git status  # verify credentials/ not tracked

# Use separate databases per site (setup script does this automatically)

# For remote dev servers, consider SSH tunneling instead of exposing MySQL:
ssh -L 3306:localhost:3306 user@dev-server
# Then connect to localhost:3306 from your local machine
```

### 5. Regular Updates

Keep your development environment updated:

```bash
# Update Docker images
docker compose pull

# Rebuild with latest versions
docker compose up -d --build

# Update Laravel dependencies in each site
docker compose exec php84 bash
cd /var/www/sites/yoursite
composer update
```

## 🔐 Development Security Checklist

- [ ] Protected `credentials/` directory (chmod 700)
- [ ] Verified credential files in `.gitignore`
- [ ] Limited MySQL exposure (localhost only or SSH tunnel preferred)
- [ ] Configured server firewall (if remote server)
- [ ] Using auto-generated strong passwords
- [ ] Regular Docker image updates
- [ ] Team access controls configured (if shared server)
- [ ] Understand this is NOT production-ready

## 🛡️ Built-in Security Features

✅ **Already Configured for Development:**
- Basic security headers
- PHP version hiding (`expose_php = Off`)
- Sensitive files blocked (.env, .git, etc.)
- Session cookie security
- Resource limits prevent DoS attacks
- Health checks detect compromised containers
- Non-root user in PHP containers
- Read-only credentials mount
- Separate databases per site

## 🚨 Transition to Production

**⚠️ IMPORTANT: When deploying to production, DO NOT use this setup as-is.**

### Production Requirements:

1. **Secrets Management**
   - AWS Secrets Manager / Parameter Store
   - HashiCorp Vault
   - Azure Key Vault
   - Kubernetes Secrets
   - Never mount credential files

2. **SSL/TLS Certificates**
   - Let's Encrypt (free, automated)
   - Cloudflare SSL
   - Load balancer termination
   - Minimum TLS 1.2

3. **Production Hardening**
   - Remove all debug/info pages
   - `APP_DEBUG=false` in Laravel
   - Enable rate limiting
   - Set up WAF (Web Application Firewall)
   - Enable logging and monitoring

4. **Infrastructure Changes**
   - Managed database services (RDS, Cloud SQL)
   - Container orchestration (Kubernetes, ECS)
   - Auto-scaling and load balancing
   - CDN for static assets
   - Automated backups with testing

5. **Security Best Practices**
   - Regular security audits
   - Dependency scanning
   - Penetration testing
   - Incident response plan
   - Access controls and MFA

## 🚨 Emergency Response

If your development server is compromised:

1. **Immediately stop containers:** `docker compose down`
2. **Check logs:** `docker compose logs > incident.log`
3. **Change all passwords** (MySQL, Laravel apps)
3. **Change all passwords** (MySQL, Laravel apps)
4. **Review access logs** in container logs
5. **Scan for malware** in `./sites` directories
6. **Restore from clean backup** if needed
7. **Update all software** before restarting
8. **Review team access** if shared server

## 📚 Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Laravel Security Best Practices](https://laravel.com/docs/security)
- [Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [Nginx Hardening Guide](https://www.cyberciti.biz/tips/linux-unix-bsd-nginx-webserver-security.html)
- [Production Deployment Checklist](https://laravel.com/docs/deployment)

---

## 💡 Remember

**This is a DEVELOPMENT environment.** It's designed for:
- ✅ Local development on your machine
- ✅ Shared development servers (with proper access controls)
- ✅ Staging/testing environments on private networks
- ❌ **NOT** for production use
- ❌ **NOT** for public-facing applications
- ❌ **NOT** for handling real user data without additional hardening
