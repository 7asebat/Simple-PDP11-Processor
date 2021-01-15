import sys
import re

Memory = {}

pre_one_op = '1001'
pre_branch = '11'
pre_no_op = '1010'
pre_jump = '1011'
instruction_opcodes = {
    'MOV':       '0000',
    'ADD':       '0001',
    'ADC':       '0010',
    'SUB':       '0011',
    'SBC':       '0100',
    'AND':       '0101',
    'OR':        '0110',
    'XOR':       '0111',
    'CMP':       '1000',
    'INC':       pre_one_op + '0000',
    'DEC':       pre_one_op + '0001',
    'CLR':       pre_one_op + '0010',
    'INV':       pre_one_op + '0011',
    'LSR':       pre_one_op + '0100',
    'ROR':       pre_one_op + '0101',
    'ASR':       pre_one_op + '0110',
    'LSL':       pre_one_op + '0111',
    'ROL':       pre_one_op + '1000',
    'BR':        pre_branch + '000',
    'BEQ':       pre_branch + '001',
    'BNE':       pre_branch + '010',
    'BLO':       pre_branch + '011',
    'BLS':       pre_branch + '100',
    'BHI':       pre_branch + '101',
    'BHS':       pre_branch + '110',
    'HLT':       pre_no_op + '0000',
    'NOP':       pre_no_op + '0001',
    'RESET':     pre_no_op + '0010',
    'JSR':       pre_jump + '0000',
    'RTS':       pre_jump + '0001',
    'INTERRUPT': pre_jump + '0010',
    'IRET':      pre_jump + '0011',
}
labels = {}
variables = {}
addressing_mode_opcodes = {
    'reg_direct':              '000',
    'reg_indirect':            '001',
    'auto_increment':          '010',
    'auto_increment_indirect': '011',
    'auto_decrement':          '100',
    'auto_decrement_indirect': '101',
    'indexed':                 '110',
    'indexed_indirect':        '111',
}
register_opcodes = {
    'R0': '000',
    'R1': '001',
    'R2': '010',
    'R3': '011',
    'R4': '100',
    'R5': '101',
    'R6': '110',
    'R7': '111',
}
two_op_instructions = [
    'MOV',
    'ADD',
    'ADC',
    'SUB',
    'SBC',
    'AND',
    'OR',
    'XOR',
    'CMP',
]
one_op_instructions = [
    'INC',
    'DEC',
    'CLR',
    'INV',
    'LSR',
    'ROR',
    'ASR',
    'LSL',
    'ROL',
]
branch_instructions = [
    'BR',
    'BEQ',
    'BNE',
    'BLO',
    'BLS',
    'BHI',
    'BHS',
]
no_op_instructions = ['HLT', 'NOP', 'RESET']
jsr_instructions = ['JSR', 'RTS', 'INTERRUPT', 'IRET']


def get_addressing_mode(op, curr_addr):
    tempBitString = ['', '']
    register = re.search('R[0-7]', op)
    if register:
        register = register.group(0)

    if re.match('^R[0-7]$', op):
        tempBitString[0] += addressing_mode_opcodes['reg_direct'] \
            + register_opcodes[register]

    elif re.match(r"^\(([^)]+)\)\+$", op):
        tempBitString[0] += addressing_mode_opcodes['auto_increment'] \
            + register_opcodes[register]

    elif re.match(r"^\-\(([^)]+)\)$", op):
        tempBitString[0] += addressing_mode_opcodes['auto_decrement'] \
            + register_opcodes[register]

    elif re.match(r"^\d+\(([^)]+)\)$", op):
        tempBitString[0] += addressing_mode_opcodes['indexed'] \
            + register_opcodes[register]
        tempBitString[1] = f"{int(op.split('(')[0]):016b}"

    elif re.match(r"^\@R[0-7]$", op):
        tempBitString[0] += addressing_mode_opcodes['reg_indirect'] \
            + register_opcodes[register]

    elif re.match(r"^\@\(([^)]+)\)\+$", op):
        tempBitString[0] += \
            addressing_mode_opcodes['auto_increment_indirect'] \
            + register_opcodes[register]

    elif re.match(r"^\@\-\(([^)]+)\)$", op):
        tempBitString[0] += \
            addressing_mode_opcodes['auto_decrement_indirect'] \
            + register_opcodes[register]

    elif re.match(r"^\@\d+\(([^)]+)\)$", op):
        tempBitString[0] += addressing_mode_opcodes['indexed_indirect'] \
            + register_opcodes[register]
        tempBitString[1] = f"{int(op[1:].split('(')[0]):016b}"

    elif re.match(r"^\#\d+$", op):
        value = int(re.search(r"\d+", op).group(0))
        tempBitString[0] += addressing_mode_opcodes['auto_increment'] \
            + register_opcodes['R7']
        tempBitString[1] = f"{value:016b}"

    elif re.match(r'^[A-Z]+$', op):
        variable = op
        if variable in variables:
            address = variables[variable]['address']
            tempBitString[0] += addressing_mode_opcodes['indexed'] \
                + register_opcodes['R7']
            offset = address-(curr_addr+2)
            tempBitString[1] += f"{offset & 0xFFFF:016b}"

        else:
            address = '[' + variable + ']'
            tempBitString[0] += addressing_mode_opcodes['indexed'] \
                + register_opcodes['R7']
            tempBitString[1] = address
    else:
        print('Error in parsing addressing mode')
        sys.exit(1)

    return tempBitString


def handle_two_op_instruction(op1, op2, curr_addr):
    firstOpBits = get_addressing_mode(op1, curr_addr)
    secondOpBits = get_addressing_mode(op2, curr_addr)
    operandsBitString = firstOpBits[0] + secondOpBits[0]
    returnedBitArr = [firstOpBits[0] + secondOpBits[0], firstOpBits[1], secondOpBits[1]]
    return returnedBitArr


def handle_one_op_instruction(op, curr_addr):
    opBits = get_addressing_mode(op, curr_addr)
    returnedBitArr = [opBits[0] + '0' * (8 - len(opBits[0])), opBits[1]]
    return returnedBitArr


def build_lookup_table(filePath):
    table = {}
    with open(filePath, 'r') as f:
        keyValueList = [x for x in f.read().splitlines() if x]
        for kv in keyValueList:
            string, code = kv.split()
            table[string] = code

    return table


def define_variable(line, variables, Memory, curr_addr):
    variable = line.split(' ')
    variable = list(filter(lambda x: bool(x), variable))
    variables[variable[1]] = {
        'address': curr_addr,
        'values': list(map(int, variable[2].split(',')))
    }

    for value in variables[variable[1]]['values']:
        Memory[curr_addr] = f"{int(value) & 0xFFFF:016b}"
        curr_addr += 1

    return curr_addr


def define_label(line, labels, curr_addr):
    label = line.split(':')[0].upper()
    labels[label] = curr_addr


def sanitize_line(line):
    line = re.split(';', line)[0]  # removing comments from each line
    instructionString = re.split(':', line)[-1].strip().upper()  # removing labels
    instruction = re.split(r",|\s", instructionString)
    instruction = list(filter(lambda x: bool(x), instruction))
    return instruction


def sanitize_label(key, value, labels, Memory):
    if re.search(r"\{\w+\}", value):
        label = re.search(r"\{(\w+)\}", value).group(1)
        if re.match('^\{', value):
            address = f"{labels[label]:016b}"
            newValue = value.replace('{' + label + '}', address)
        else:
            offset = labels[label] - (key + 1)
            if not -128 <= offset <= 127:
                print('Offset out of range for label {label}')
                sys.exit(1)
            newValue = value.replace('{' + label + '}', '000' + f"{offset & 0xFF:08b}")
        # Updating Memory Value
        Memory[key] = newValue


def sanitize_variable(key, value, variables, Memory):
    if re.search(r"\[\w+\]", value):
        var = re.search(r"\[(\w+)\]", value).group(1)
        print(var)
        offset = variables[var]['address'] - (key + 1)
        Memory[key] = f"{offset & 0xFFFF:016b}"


def process_two_op(instruction, bitString, Memory, curr_addr):
    two_op_result = handle_two_op_instruction(instruction[1], instruction[2], curr_addr)

    # Constructing Memory
    Memory[curr_addr] = bitString + two_op_result[0]  # instruction in memory

    if two_op_result[1]:
        curr_addr += 1
        Memory[curr_addr] = two_op_result[1]

    if two_op_result[2]:
        curr_addr += 1
        Memory[curr_addr] = two_op_result[2]

    return curr_addr


def process_one_op(instruction, bitString, Memory, curr_addr):
    one_op_result = handle_one_op_instruction(instruction[1], curr_addr)

    # Constructing Memory
    Memory[curr_addr] = bitString + one_op_result[0]

    if one_op_result[1]:
        curr_addr += 1
        Memory[curr_addr] = one_op_result[1]

    return curr_addr


def process_branch(instruction, bitString, Memory, curr_addr, index):
    if len(instruction) > 2:
        print('Branch instruction expects a label only, in line', index + 1)
        sys.exit(1)

    label = instruction[1]

    if label not in labels:
        # Constructing Memory
        Memory[curr_addr] = bitString + '{' + label + '}'

    else:
        offset = labels[label] - (curr_addr + 1)

        if not -128 <= offset <= 127:
            print('Offset out of range in line', index + 1)
            sys.exit(1)

        # Constructing Memory
        Memory[curr_addr] = bitString + '000' + f"{offset & 0xFF:08b}"

    return curr_addr


def process_no_op(instruction, bitString, Memory, curr_addr, index):
    if len(instruction) > 1:
        print('no-operand instruction', instruction[0],
              'expects no operands, in line', index + 1)
        sys.exit(1)

    # Constructing Memory
    Memory[curr_addr] = bitString + '0' * (16 - len(bitString))

    return curr_addr


def process_jsr(instruction, bitString, Memory, curr_addr, index):
    if instruction[0] == 'JSR':
        if len(instruction) > 2:
            print('JSR instruction expects a label only, in line', index + 1)
            sys.exit(1)

        Memory[curr_addr] = bitString + '0' * (16 - len(bitString))
        curr_addr += 1
        label = instruction[1]
        if label in labels:
            Memory[curr_addr] = f"{labels[label]:016b}"
        else:
            Memory[curr_addr] = '{' + label + '}'
    else:
        # Constructing Memory
        Memory[curr_addr] = bitString + '0' * (16 - len(bitString))

    return curr_addr


def write_memory_to_file(filePath):
    with open(filePath, 'w+b') as f:
        for i in sorted(Memory):
            word = int(Memory[i], 2).to_bytes(2, byteorder='big')
            f.write(word)


def writeDoFile(fn, memoryImport):
    with open(f'{fn}.do', 'w') as f:
        f.write(fr'''
vsim work.processor

{memoryImport}

add wave -dec -position insertpoint \
\
sim:/processor/Rx_out(7) \
sim:/processor/CTRL_COUNTER_out \
sim:/processor/uPC_out \
\
-dec \
sim:/processor/MDR_out \
sim:/processor/MAR_out \
\
-bin \
{{sim:/processor/Rstatus_out[2:0]}} \
\
-dec \
sim:/processor/Rx_out \

# bin \
# sim:/processor/ALU_flags \
# sim:/processor/ALU_F \
# sim:/processor/ALU_Cin \

# -dec \
# sim:/processor/INT_SRC_out \
# sim:/processor/INT_DST_out \

# -hex \
# sim:/processor/CTRL_SIGNALS \
# sim:/processor/uIR_sig \
# sim:/processor/IR_out \
# sim:/processor/shared_bus \
# sim:/processor/WMFC \
# sim:/processor/MFC \
# sim:/processor/RUN \
# sim:/processor/clk \
# sim:/processor/MIU_read \
# sim:/processor/MIU_write \
# sim:/processor/MIU_mem_write \
# sim:/processor/MIU_mem_read \

# sim:/processor/MDR_REGISTER/A_en \
# sim:/processor/MDR_REGISTER/A_in \
# sim:/processor/MDR_REGISTER/B_en \
# sim:/processor/MDR_REGISTER/B_in \
# sim:/processor/RAM/dataIn \
# sim:/processor/RAM/dataOut \

force -freeze sim:/processor/clk 1 0 
force -freeze sim:/processor/uPC_reset 1 0 
force -freeze sim:/processor/MIU_reset 1 0 
force -freeze sim:/processor/Rz_reset 1 0 
force -freeze sim:/processor/Ry_reset 1 0 
force -freeze sim:/processor/Rstatus_reset 1 0 
force -freeze sim:/processor/MDR_reset 1 0 
force -freeze sim:/processor/MAR_reset 1 0 
force -freeze sim:/processor/IR_reset 1 0 
force -freeze sim:/processor/INT_SRC_reset 1 0 
force -freeze sim:/processor/INT_DST_reset 1 0 
force -freeze sim:/processor/HALT_reset 1 0 
force -freeze sim:/processor/CTRL_COUNTER_reset 1 0 
force -freeze sim:/processor/Rx_reset 11111111 0 
run 

noforce sim:/processor/uPC_reset 
noforce sim:/processor/MIU_reset 
noforce sim:/processor/Rz_reset 
noforce sim:/processor/Ry_reset 
noforce sim:/processor/Rx_reset 
noforce sim:/processor/Rstatus_reset 
noforce sim:/processor/MDR_reset 
noforce sim:/processor/MAR_reset 
noforce sim:/processor/IR_reset 
noforce sim:/processor/INT_SRC_reset 
noforce sim:/processor/INT_DST_reset 
noforce sim:/processor/HALT_reset 
noforce sim:/processor/CTRL_COUNTER_reset 
noforce sim:/processor/Rx_reset 
force -freeze sim:/processor/clk 1 0, 0 {{50 ps}} -r 100 

run 100ns;
''')
