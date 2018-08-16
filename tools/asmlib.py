def lst2asm(lst, perline=8):
    res = []
    for i,v in enumerate(lst):
        if i%perline == 0:
            if i != 0:
                res.append('\n')
            res.append('\tdc.b ')
        else:
            res.append(', ')
        res.append("${:02x}".format(v))
    return ''.join(res)
