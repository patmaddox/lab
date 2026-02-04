-- Example Lua file

local Person = {}
Person.__index = Person

function Person:new(name, age)
    local self = setmetatable({}, Person)
    self.name = name
    self.age = age
    return self
end

function Person:greet()
    return string.format("Hello, my name is %s", self.name)
end

local function process_items(items)
    local result = {}
    for _, item in ipairs(items) do
        if #item > 3 then
            table.insert(result, string.upper(item))
        end
    end
    return result
end

local person = Person:new("Alice", 30)
print(person:greet())

local items = {"foo", "bar", "hello", "world"}
for _, item in ipairs(process_items(items)) do
    print(item)
end
