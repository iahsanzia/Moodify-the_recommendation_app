# 🔒 Security Guidelines for Moodify

## ⚠️ IMPORTANT: Immediate Security Actions Required

### 1. Credential Rotation (DO THIS NOW!)

If you've exposed any of these credentials:

#### MongoDB
- [ ] Change password in MongoDB Atlas dashboard
- [ ] Update connection string in `.env`

#### JWT Secret  
- [ ] Generate strong secret: `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`
- [ ] Update `JWT_SECRET` in `.env`

#### TMDB API
- [ ] Regenerate API key in TMDB account settings
- [ ] Update `TMDB_ACCESS_TOKEN` in `.env`

#### Spotify API
- [ ] Regenerate Client ID & Secret in Spotify Developer Console
- [ ] Update credentials in `.env`

### 2. Environment Variables

#### ✅ DO:
- Use `.env.example` for templates
- Keep `.env` in `.gitignore`
- Use strong, random secrets
- Rotate credentials regularly

#### ❌ DON'T:
- Commit `.env` files to Git
- Use weak or default passwords
- Share credentials in chat/email
- Use production credentials in development

### 3. API Security

#### Rate Limiting
- Auth endpoints: 100 requests/15 minutes per IP
- General endpoints: Consider implementing as needed

#### Headers
- `helmet.js` for security headers
- CORS restricted to specific domains in production

#### Input Validation
- Validate all user inputs
- Sanitize file uploads
- Limit payload sizes

### 4. Database Security

#### MongoDB Best Practices:
- Use strong passwords (20+ characters)
- Enable IP whitelisting
- Use connection string with SSL
- Regular security updates

### 5. Deployment Security

#### Production Checklist:
- [ ] Use HTTPS only
- [ ] Set `NODE_ENV=production`
- [ ] Remove development tools
- [ ] Enable audit logging
- [ ] Use security scanning tools

### 6. Code Security

#### Dependencies:
```bash
# Regular security audits
npm audit
npm audit fix

# Check for vulnerabilities
npm install -g npm-check-updates
ncu -u
```

#### Sensitive Data Detection:
```bash
# Install git-secrets to prevent credential commits
git secrets --register-aws
git secrets --install
```

### 7. Monitoring

#### Security Monitoring:
- Monitor failed authentication attempts
- Log suspicious API activity
- Set up alerts for unusual patterns
- Regular security reviews

### 8. Emergency Response

#### If Credentials Are Compromised:
1. **Immediately** rotate all affected credentials
2. Review access logs for unauthorized activity
3. Notify users if data may be affected
4. Document the incident
5. Implement additional security measures

### 9. Regular Security Tasks

#### Weekly:
- [ ] Review access logs
- [ ] Check for dependency updates

#### Monthly:
- [ ] Rotate API keys
- [ ] Security audit review
- [ ] Update security documentation

#### Quarterly:
- [ ] Full security assessment
- [ ] Penetration testing
- [ ] Security training review

---

## 🚨 Emergency Contacts

- Security Issues: [your-security-email]
- MongoDB Support: [mongodb-support]
- API Provider Support: [api-providers]

Remember: **Security is everyone's responsibility!**
