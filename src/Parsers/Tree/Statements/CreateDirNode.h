#ifndef __CREATE_DIR_NODE_H_
#define __CREATE_DIR_NODE_H_

#include <filesystem>
#include <string>

#include "StatementNode.h"

namespace fs = std::filesystem;

namespace FileManager
{
    class CreateDirNode : public StatementNode
    {
    protected:
        // TODO: change to custom type.
        std::string dir;

        bool createIfNotExists = false;

    public:
        CreateDirNode(const char *dir, bool createIfNotExists = false);

        CreateDirNode(const std::string &dir, bool createIfNotExists = false);

        virtual ~CreateDirNode() = default;

        virtual bool Execute();

        virtual void DumpTree(std::ostream &out, int indent = 0) const;
    };
}

#endif
