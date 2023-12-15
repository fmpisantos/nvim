import subprocess
import html

def writeToFile(path, content):
    with open(path, "w") as file:
        file.write(content)

def runGrep():
    command = ["grep", "-r", "^vim\.keymap\.set", "../"]
    try:
        output = subprocess.check_output(command, text=True, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        output = e.stderr
    return output

def parseStr(alias): 
    # alias example
    # ./grep_vim.keymap.set.lua:vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
    # parsedCommands format:
    # [[mode, command, function], ...]
    lines = alias.split('\n')
    lines = [line[line.find('(')+1:] for line in lines] 
    lines = [line[:line.rfind(')')] for line in lines] 
    return [line.split(',') for line in lines]

def getItem(line, idx):
    return line[idx] if len(line) > idx else ""

def getFunction(item):
    return item.replace("function() ", "").replace(" end", "")

def getMode(items):
    idx = 0
    mode = ""
    if '{' in items[0]:
         for item in items:
            mode += item
            if "}" in item:
                return mode, idx
            idx = idx + 1
    return getItem(items, 0), idx
def printPrettyMD(matrix):
    toPrint = "# Keybinds \n| Function | Keybind | Mode | Opts |\n|----------------------|--------------|------|------|"
    toPrint += "\n| :Gdiff | dv | n |  |"
    toPrint += "\n| <cmd>diffget //2<CR> | gh | n | Get left in conflict (in :Gdiff) |"
    toPrint += "\n| <cmd>diffget //3<CR> | gl | n | Get right in conflict (in :Gdiff) |"
    for line in matrix:
        mode, idx = getMode(line)
        toPrint += f"\n| {getFunction(getItem(line,idx+2))} | {getItem(line,idx+1)} | {mode} | {getItem(line,idx+3)} |"
    return toPrint
    
def main():
    # grep -r '^vim.keymap.set' ./
    grepStr = runGrep()
    # writeToFile("grep.txt",grepStr)
    parsedStr = parseStr(grepStr)
    printStr = printPrettyMD(parsedStr)
    writeToFile("../pretty.md", html.escape(printStr))
    
if __name__ == "__main__":
    main()
