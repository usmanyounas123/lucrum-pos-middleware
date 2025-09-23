# 🚨 SECURITY CONFIGURATION CHECKLIST

## BEFORE DEPLOYING TO PRODUCTION

### ✅ MANDATORY SECURITY CHANGES

1. **Change JWT Secret**
   ```
   JWT_SECRET=your-super-secure-random-string-here-min-32-chars
   ```
   - Use a random string generator
   - Minimum 32 characters
   - Include letters, numbers, symbols

2. **Change Admin API Key**
   ```
   ADMIN_API_KEY=your-secure-admin-key-here
   ```
   - Use a strong, unique key
   - Share only with authorized personnel

3. **Update CORS Origins**
   ```
   ALLOWED_ORIGINS=http://192.168.1.100:3000,https://yourpos.company.com
   ```
   - Replace with your actual POS system URLs
   - Remove localhost entries in production

### 🔒 RECOMMENDED SECURITY MEASURES

1. **Network Security**
   - Use HTTPS in production (configure reverse proxy)
   - Restrict access to internal network only
   - Configure Windows Firewall rules

2. **File Permissions**
   - Ensure service runs with minimal required permissions
   - Protect `.env` file from unauthorized access
   - Regular backup of `data.db`

3. **Monitoring**
   - Monitor `logs/app.log` for suspicious activity
   - Set up alerts for service failures
   - Regular security updates

### 🚫 WHAT NOT TO DO

- ❌ Don't use default JWT_SECRET in production
- ❌ Don't expose ports to the internet unnecessarily
- ❌ Don't share API keys in plain text
- ❌ Don't ignore log files and monitoring

---
**IMPORTANT**: Test all changes in a development environment first!