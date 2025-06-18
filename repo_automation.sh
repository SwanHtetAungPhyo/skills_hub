#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 Setting up Git hooks for branch protection...${NC}"

mkdir -p .git/hooks

cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Get current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Protected branches
protected_branches=("main" "master" "develop")

# Check if current branch is protected
for branch in "${protected_branches[@]}"; do
    if [[ "$current_branch" == "$branch" ]]; then
        echo -e "${RED}❌ Direct commits to '$branch' branch are not allowed!${NC}"
        echo -e "${YELLOW}📝 Please create a feature branch instead:${NC}"
        echo -e "${GREEN}   git checkout -b feature/your-feature-name${NC}"
        echo -e "${GREEN}   git add .${NC}"
        echo -e "${GREEN}   git commit -m 'Your commit message'${NC}"
        echo -e "${GREEN}   git push origin feature/your-feature-name${NC}"
        echo ""
        echo -e "${YELLOW}💡 Then create a Pull Request to merge your changes.${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ Commit allowed on branch: $current_branch${NC}"
EOF

chmod +x .git/hooks/pre-commit

echo -e "${GREEN}✅ Git hooks installed successfully!${NC}"
echo -e "${YELLOW}📋 Now developers must create feature branches to commit changes.${NC}"