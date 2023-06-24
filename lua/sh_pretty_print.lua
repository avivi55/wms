AddCSLuaFile()
local function print_table(tab, cur_depth, max_depth)
    if cur_depth > max_depth then return tostring(tab)..",\n" end

    local result = ""
    local base_space = "   "
    local space_str  = cur_depth <= 1 and "" or string.rep(base_space,cur_depth-1)
    local space_str2 = space_str..base_space

    result = ((cur_depth > 1) and "\n" or "")..space_str.."{\n"
    for k, v in pairs(tab) do
        result = result..space_str2..tostring(k).." :"
        if type(v) == "table" then
            result = result..print_table(v, cur_depth + 1, max_depth)
        else
            result = result..tostring(v).."\n"
        end

    end
    result = result..space_str..(cur_depth > 1 and "}\n" or "}")

    return result
end


function PrintC(var, mode, fg_ansi, ...)
    fg_ansi = tostring(fg_ansi)
    local bg_ansi = {...}
    bg_ansi = bg_ansi[1] or ""
    bg_ansi = tostring(bg_ansi)

    local color_ansi = ""

    if (isstring(bg_ansi) and bg_ansi ~= "") then
        if (mode == 24) then color_ansi = "\27[38;2;"..fg_ansi.."m".."\27[48;2;"..bg_ansi.."m"
        elseif (mode == 8) then color_ansi = "\27[38;5;"..fg_ansi.."m".."\27[48;5;"..bg_ansi.."m" end
    else
        if (mode == 24) then color_ansi = "\27[38;2;"..fg_ansi.."m"
        elseif (mode == 8) then color_ansi = "\27[38;5;"..fg_ansi.."m" end
    end

    print(color_ansi)

    if type(var) == "table" then
        local str = print_table(var, 1, 15)
        if (system.IsLinux or system.IsOSX) then
            str = color_ansi..str.."\27[39m\27[49m"
        end
        print(str)
    else
        local str = tostring(var)
        if (system.IsLinux or system.IsOSX) then
            str = color_ansi..str.."\27[39m\27[49m"
        end
        print(str)
    end
end

function Print(...)
    args = {...}
    local str = print_table(args, 1, 15)
    print(str)
end
