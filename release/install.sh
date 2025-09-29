#!/bin/bash

# POS Middleware Installation Script
# This script will install and set up the POS Middleware on your system

echo "======================================"
echo "POS Middleware v2.0.0 Installation"
echo "======================================"

# Check if Node.js is installed
echo "Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed!"
    echo "Please install Node.js 14 or higher from https://nodejs.org/"
    echo "Then run this script again."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node --version | cut -d'v' -f2)
MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1)

if [ "$MAJOR_VERSION" -lt 14 ]; then
    echo "❌ Node.js version $NODE_VERSION is too old!"
    echo "Please install Node.js 14 or higher from https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js version $NODE_VERSION detected"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed!"
    echo "Please install npm (usually comes with Node.js)"
    exit 1
fi

echo "✅ npm is available"

# Install dependencies
echo ""
echo "Installing dependencies..."
npm install --only=production

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"

# Create start script
echo ""
echo "Creating start script..."

cat > start.sh << 'EOF'
#!/bin/bash
echo "Starting POS Middleware..."
echo "Server will be available at: http://localhost:8081"
echo "Test interface: http://localhost:8082 (if you run: python3 -m http.server 8082)"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
node dist/index.js
EOF

chmod +x start.sh

# Create stop script
cat > stop.sh << 'EOF'
#!/bin/bash
echo "Stopping POS Middleware..."
pkill -f "node dist/index.js"
echo "POS Middleware stopped"
EOF

chmod +x stop.sh

# Create status script
cat > status.sh << 'EOF'
#!/bin/bash
if pgrep -f "node dist/index.js" > /dev/null; then
    echo "✅ POS Middleware is running"
    echo "Server: http://localhost:8081"
    
    # Test if server is responding
    if curl -s http://localhost:8081/api/health > /dev/null 2>&1; then
        echo "✅ Server is responding to requests"
    else
        echo "⚠️  Server process found but not responding"
    fi
else
    echo "❌ POS Middleware is not running"
    echo "Run './start.sh' to start the server"
fi
EOF

chmod +x status.sh

echo "✅ Management scripts created"
echo ""
echo "======================================"
echo "Installation Complete! 🎉"
echo "======================================"
echo ""
echo "Quick Start:"
echo "1. Start the server: ./start.sh"
echo "2. Check status: ./status.sh"
echo "3. Stop the server: ./stop.sh"
echo ""
echo "Server will run on: http://localhost:8081"
echo "API Documentation: See README.md"
echo "Test Interface: Open order-api-tester.html in browser"
echo ""
echo "For help, see README.md or contact support."