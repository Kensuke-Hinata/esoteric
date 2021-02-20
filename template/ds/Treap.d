import std.stdio, std.string;
import std.random, std.algorithm;

class Treap(T)
{
    protected class Node
    {
        Node left;
        Node right;
        T val;
        long priority;
        int size;   // subtree size
        int distinct;   // subtree distinct size
        int count;  // count for the same value

        this()
        {
            left = right = null;
            size = count = distinct = 1;
        }

        int cmpPriority(long priority)
        {
            if (this.priority == priority) return 0;
            return this.priority < priority ? -1 : 1;
        }

        int cmpVal(T val)
        {
            if (this.val == val) return 0;
            return this.val < val ? -1 : 1;
        }
    }

    protected Node root;
    protected Xorshift rnd;
    protected T minimal;
    protected T maximal;

    this()
    {
        root = null;
        rnd = Xorshift(1234567891);
        minimal = T.max;
        maximal = T.min;
    }

    protected void leftRotate(ref Node node)
    {
        auto rightNode = node.right;
        if (rightNode)
        {
            node.size = node.count;
            node.distinct = 1;
            if (node.left)
            {
                node.size += node.left.size;
                node.distinct += node.left.distinct;
            }
            if (rightNode.left)
            {
                node.size += rightNode.left.size;
                node.distinct += rightNode.left.distinct;
            }
            rightNode.size = rightNode.count + node.size;
            rightNode.distinct = 1 + node.distinct;
            if (rightNode.right)
            {
                rightNode.size += rightNode.right.size;
                rightNode.distinct += rightNode.right.distinct;
            }
            node.right = rightNode.left;
            rightNode.left = node;
            node = rightNode;
        }
    }

    protected void rightRotate(ref Node node)
    {
        auto leftNode = node.left;
        if (leftNode)
        {
            node.size = node.count;
            node.distinct = 1;
            if (node.right)
            {
                node.size += node.right.size;
                node.distinct += node.right.distinct;
            }
            if (leftNode.right)
            {
                node.size += leftNode.right.size;
                node.distinct += leftNode.right.distinct;
            }
            leftNode.size = leftNode.count + node.size;
            leftNode.distinct = 1 + node.distinct;
            if (leftNode.left)
            {
                leftNode.size += leftNode.left.size;
                leftNode.distinct += leftNode.left.distinct;
            }
            node.left = leftNode.right;
            leftNode.right = node;
            node = leftNode;
        }
    }

    protected Node find(T val)
    {
        return _find(root, val);
    }

    protected Node _find(Node node, T val)
    {
        if (!node) return null;
        auto ret = node.cmpVal(val);
        if (ret == 0) return node;
        if (ret == -1) return _find(node.right, val);
        return _find(node.left, val);
    }

    public void insert(T val)
    {
        _insert(root, val);
    }

    protected int _insert(ref Node node, T val)
    {
        if (!node)
        {
            node = new Node();
            node.val = val;
            node.priority = this.rnd.front;
            this.rnd.seed(unpredictableSeed);
            return 1;
        }
        auto ret = node.cmpVal(val);
        if (ret == 0)
        {
            ++ node.count;
            ++ node.size;
            return 0;
        }
        int res;
        if (ret == 1)
        {
            res = _insert(node.left, val);
            if (node.left.priority > node.priority)
            {
                rightRotate(node);
            }
            else
            {
                ++ node.size;
                if (res == 1) ++ node.distinct;
            }
        }
        else
        {
            res = _insert(node.right, val);
            if (node.right.priority > node.priority)
            {
                leftRotate(node);
            }
            else
            {
                ++ node.size;
                if (res == 1) ++ node.distinct;
            }
        }
        return res;
    }

    public void remove(T val)
    {
        _remove(root, val);
    }

    protected int _remove(ref Node node, T val)
    {
        if (!node) return -1;
        auto ret = node.cmpVal(val);
        if (ret == -1)
        {
            auto res = _remove(node.right, val);
            if (res != -1) -- node.size;
            if (res == 1) -- node.distinct;
            return res;
        }
        else if (ret == 1)
        {
            auto res = _remove(node.left, val);
            if (res != -1) -- node.size;
            if (res == 1) -- node.distinct;
            return res;
        }
        if (node.count > 1)
        {
            -- node.count;
            -- node.size;
            return 0;
        }
        if (!node.left && !node.right)
        {
            node = null;
            return 1;
        }
        if (!node.left)
        {
            node = node.right;
            return 1;
        }
        if (!node.right)
        {
            node = node.left;
            return 1;
        }
        int res;
        if (node.left.cmpPriority(node.right.priority) == 1) 
        {
            rightRotate(node);
            res = _remove(node.right, val);
        }
        else
        {
            leftRotate(node);
            res = _remove(node.left, val);
        }
        -- node.size;
        -- node.distinct;
        return 1;
    }

    protected int _countLess(Node node, T val)
    {
        if (!node) return 0;
        if (node.val == val)
        {
            if (node.left) return node.left.size;
            return 0;
        }
        if (node.val < val)
        {
            auto res = _countLess(node.right, val);
            ++ res;
            if (node.left) res += node.left.size;
            return res;
        }
        return _countLess(node.left, val);
    }

    public int countLess(T val)
    {
        return _countLess(root, val);
    }

    protected int _countGreater(Node node, T val)
    {
        if (!node) return 0;
        if (node.val == val)
        {
            if (node.right) return node.right.size;
            return 0;
        }
        if (node.val > val)
        {
            auto res = _countGreater(node.left, val);
            ++ res;
            if (node.right) res += node.right.size;
            return res;
        }
        return _countGreater(node.right, val);
    }

    public int countGreater(T val)
    {
        return _countGreater(root, val);
    }

    protected T _getMinimal(Node node)
    {
        if (!node) return minimal; 
        if (!node.left) return node.val;
        return _getMinimal(node.left);
    }

    public T getMinimal()
    {
        return _getMinimal(root);
    }

    protected T _getMaximal(Node node)
    {
        if (!node) return maximal;
        if (!node.right) return node.val;
        return _getMaximal(node.right);
    }

    public T getMaximal()
    {
        return _getMaximal(root);
    }

    public void travel()
    {
        _travel(root);
    }

    protected void _travel(Node node)
    {
        if (!node) return;
        _travel(node.left);
        writeln(node.val);
        writeln(node.priority);
        writeln(node.size);
        _travel(node.right);
    }

    public void clear()
    {
        while (root)
        {
            remove(root.val);
        }
    }

    @property public int size()
    {
        return root.size;
    }

    @property public int distinct()
    {
        return root.distinct;
    }
}

unittest
{
    writeln("unit test");
    auto treap = new Treap!int();
    auto lst = [1, 3, 2, 4, 6, 5, 8, 7, 10, 9];
    writeln("insert");
    foreach (val; lst)
    {
        treap.insert(val);
    }
    treap.travel();
    writeln("remove");
    lst = [1, 5, 10];
    foreach (val; lst)
    {
        treap.remove(val);
    }
    treap.travel();
    writeln("clear");
    treap.clear();
    treap.travel();
}

int main(string[] args)
{
    return 0;
}
