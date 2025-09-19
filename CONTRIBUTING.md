# Contributing to Lucrum POS Middleware

We welcome contributions to the Lucrum POS Middleware project! This document provides guidelines for contributing.

## 🚀 How to Contribute

### 1. Fork the Repository
1. Fork this repository to your GitHub account
2. Clone your fork locally
3. Create a new branch for your feature/fix

### 2. Development Setup
```bash
# Clone your fork
git clone https://github.com/yourusername/lucrum-pos-middleware.git
cd lucrum-pos-middleware

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
```

### 3. Making Changes
1. Make your changes in a feature branch
2. Test your changes thoroughly
3. Update documentation if needed
4. Ensure all existing tests pass
5. Add new tests for new functionality

### 4. Testing
```bash
# Run tests
npm test

# Test the build
npm run build

# Test the Windows executable (if applicable)
npm run build-exe
```

### 5. Submitting Changes
1. Commit your changes with clear, descriptive messages
2. Push to your fork
3. Create a Pull Request with detailed description
4. Reference any related issues

## 📝 Commit Message Guidelines

Use clear, descriptive commit messages:
```
feat: add new Lucrum sales order endpoint
fix: resolve WebSocket connection timeout issue
docs: update API documentation
refactor: simplify batch file structure
test: add unit tests for order validation
```

## 🐛 Reporting Issues

When reporting issues, please include:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment details (Windows version, Node.js version)
- Log files if relevant

## 📋 Development Guidelines

### Code Style
- Use TypeScript for all new code
- Follow existing code formatting
- Add JSDoc comments for public APIs
- Use meaningful variable and function names

### Batch Files
- Keep batch files simple and focused
- Include clear error messages
- Test on different Windows versions
- Add comments for complex operations

### Documentation
- Update README.md for new features
- Add examples for new APIs
- Keep documentation current with code changes

## 🎯 Areas for Contribution

We especially welcome contributions in these areas:
- API endpoint improvements
- WebSocket functionality enhancements
- Windows service reliability
- Documentation improvements
- Testing and quality assurance
- Performance optimizations

## 📞 Getting Help

If you need help:
- Check existing issues and documentation
- Create a new issue with your question
- Be specific about what you're trying to achieve

## 🏆 Recognition

Contributors will be acknowledged in:
- CONTRIBUTORS.md file
- Release notes for significant contributions
- GitHub contributors list

Thank you for contributing to Lucrum POS Middleware! 🎉