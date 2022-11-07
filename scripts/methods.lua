-- guess why is all of this here? hehe

function new_table(n, value)
	local t = {}
	for i = 1, n do t[#t + 1] = value or 0 end
	return t
end

function sum(table_a, table_b)
	assert(#table_a == #table_b)
	local t = {}
	for i = 1, #table_a do
		t[i] = table_a[i] + table_b[i]
	end
end

function transpose(matrix)
	-- transpose a matrix
	local m = {}
	for i = 1, #matrix[1] do m[i] = {} end
	for i = 1, #matrix do
		for j = 1, #matrix[1] do
			m[j][i] = matrix[i][j]
		end
	end
	return m
end

function vector_multiplication(vector_a, vector_b)
	assert(#vector_a == #vector_b)
	local result = 0
	for i = 1, #vector_a do
		result = result + vector_a[i] * vector_b[i]
	end
	return result
end

function exp(vector)
	local v = {}
	for i = 1, #vector do
		v[i] = 2.71828182 ^ vector[i]
	end
	return v
end

function max(vector)
	local m, f = 0, true
	for i = 1, #vector do
		if (m < vector[i] or f) then
			m = vector[i]
			f = false
		end
	end
	return m
end

function min(vector)
	local m, f = 0, true
	for i = 1, #vector do
		if (m > vector[i] or f) then
			m = vector[i]
			f = false
		end
	end
	return m
end

require'math'
function log(vector)
	local v = {}
	for i = 1, #vector do
		v[i] = math.log(vector[i])
	end
	return v
end

function matrices_multiplication(matrix_a, matrix_b)
	local v = {}
	for i = 1, #matrix_b do
		local b = {}
		for j = 1, #matrix_a do
			b[i] = vector_multiplication(matrix_a[j], matrix_b[i])
		end
		v[i] = b
	end
	return v
end

function matrix_dot_vector(matrix, vector)
	local v = {}
	for i = 1, #matrix do
		v[i] = vector_multiplication(matrix[i], vector)
	end
	return v
end

function determine_line_coefficients(dot_a, dot_b)

end

function vector_length(vector)
	local s = 0
	for _, v in ipairs(vector) do
		s = s + v^2
	end
	s = math.sqrt(s)
	return s
end

local layout = {326,326,326,326,326,326}

local input_n = 326
local output_n = 15

local function LoadCheckPoints(str)

end

local function SaveCheckpoint(tbl)

end

local function InitializeRandomly(layout, input_n, output_n)
	local weights = {}
	for layer = 1, #layout do
		weights[layer] = {}
		for n = 1, #layout[layer] do
			weights[layer][n] = {}
			for i = 1, input_n do
				weights[layer][n][i] = math.random()
			end
		end
	end
end

a = InitializeRandomly(layout, input_n, output_n)

print()