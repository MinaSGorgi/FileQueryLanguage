#pragma once

#include <string>
#include <vector>

#include "Parsers/Tree/Expressions/ExpressionNode.h"

namespace FQL
{
    class FunctionNode : public ExpressionNode
    {
    protected:
        std::string name;
        std::vector<ExpressionNode*> args;

    public:
        FunctionNode(const std::string& name);

        FunctionNode(const std::string& name, const std::vector<ExpressionNode*>& args);

        virtual ~FunctionNode();

        virtual void DumpTree(std::ostream& out, int indent = 0) const;
    };
}
