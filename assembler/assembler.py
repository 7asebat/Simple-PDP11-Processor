from utility import *

if len(sys.argv) != 2:
    print('Invalid arguments')
    sys.exit(1)

with open(sys.argv[1]) as f:
    HLTCalled = False
    curr_addr = 0
    for (index, line) in enumerate(f):
        # removing extra spaces
        line = line.rstrip().strip().upper()

        # Check: if empty line ignore
        if len(line) <= 1 or line.startswith(';'):  # NEED TO BE EDITED
            continue

        # Update current address
        if '.=' in line:
            curr_addr = int(line.split('.=')[-1].strip())
            continue

        # Defining variables
        if line.startswith('DEFINE'):
            curr_addr = define_variable(line, variables, Memory, curr_addr)
            continue

        # Defining labels
        if ':' in line:
            define_label(line, labels, curr_addr)

        if HLTCalled:
            continue

        # Line sanity
        instruction = sanitize_line(line)
        if not instruction:
            continue
        print(instruction)

        # Constructing bit string
        bitString = ''

        # Load instruction opcode
        if not instruction[0] in instruction_opcodes:
            print('Error in parsing instruction: syntax error in line', index + 1)
            sys.exit(1)

        # Load instruction opcode to the bit string
        bitString += instruction_opcodes[instruction[0]]

        if instruction[0] in two_op_instructions:
            curr_addr = process_two_op(instruction, bitString, Memory, curr_addr)

        elif instruction[0] in one_op_instructions:
            curr_addr = process_one_op(instruction, bitString, Memory, curr_addr)

        elif instruction[0] in branch_instructions:
            curr_addr = process_branch(instruction, bitString, Memory, curr_addr)

        elif instruction[0] in no_op_instructions:
            curr_addr = process_no_op(instruction, bitString, Memory, curr_addr)

        elif instruction[0] in jsr_instructions:
            curr_addr = process_jsr(instruction, bitString, Memory, curr_addr)

        else:
            print('Invalid instruction: syntax error in line', index + 1)
            sys.exit(1)

        if instruction[0] == 'HLT':
            HLTCalled = True

        curr_addr += 1

# Post-processing to update labels offset
for (key, value) in Memory.items():
    sanitize_label(key, value, labels, Memory)
    sanitize_variable(key, value, variables, Memory)

write_memory_to_file('memory.bin')

print('\nVariables:')
for k, v in variables.items():
    print(k, v)

print('\nLabels:')
for k, v in labels.items():
    print(k, v)

print('\nMemory:')
for k, v in enumerate(Memory.items()):
    if(v[0] % 4 == 0):
        print(f'\n{v[0]:x}: ',end="")
    print('{val}'.format(val=v[1]),end=" ")
