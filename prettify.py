import subprocess

def writeToFile(path, content):
    with open(path, "w") as file:
        file.write(content)

def runGrep():
    command = ["grep", "-r", "^vim\.keymap\.set", "./"]
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
    lines = [line[:line.rfind(')')-1] for line in lines] 
    return [line.split(',') for line in lines]

def getItem(line, idx):
    return line[idx] if len(line) > idx else ""

def printPrettyMD(matrix):
    toPrint = "# Keybinds \n| Function | Keybind | Mode | Opts |\n|----------------------|--------------|------|------|"
    for line in matrix:
        toPrint += f"\n| {getItem(line,2)} | {getItem(line,1)} | {getItem(line,0)} | {getItem(line,3)} |"
    return toPrint
    
def main():
    # grep -r '^vim.keymap.set' ./
    grepStr = runGrep()
    writeToFile("grep.txt",grepStr)
    parsedStr = parseStr(grepStr)
    printStr = printPrettyMD(parsedStr)
    writeToFile("./pretty.md", printStr)
    
if __name__ == "__main__":
    main()
