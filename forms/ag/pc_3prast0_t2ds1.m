clear, clc
% syms u1 u2 u3
% u = [u1; u2; u3];
v = sym('v%d', [3, 1]);
unknown_vars = symvar(v);

% R = (2 * s * s - 1) * eye(3) + 2 * (u * transpose(u) - s * skew(u));
R = 2 * (v * transpose(v) - skew(v)) + (1 - transpose(v) * v) * eye(3);

q = transpose(sym('q%d%d', [3, 3]));
qq = transpose(sym('qq%d%d', [3, 3]));

eqs = sym(zeros(3 * 3, 1));
% eqs = sym(zeros(5, 1));

temp = {};

for index = 1:3
    i = index;
    j = mod(index, 3) + 1;
    k = mod(index + 1, 3) + 1;
    F = sym(zeros(3, 2));
    F(1:2, 1:2) = simpleFijk(q, qq, R, i, j, k);
    F(3, :) = [-transpose(v) * q(:, i), transpose(v) * qq(:, i)];
    temp{index} = F;
%     eqs(index) = det(F([1, 2], :));
    eqs(index * 3 - 2) = det(F([1, 2], :));
    eqs(index * 3 - 1) = det(F([2, 3], :));
    eqs(index * 3) = det(F([3, 1], :));
end

%% Verification
all_vars = [symvar(eqs), str2sym_('[Q, QQ]')];
pc_sample_data(3, true, all_vars);

for i = 1:3
    vars = symvar(temp{i});
    val = eval(subs(temp{i}, vars, vars));
    
    lambda = norm(Q(:, i));
    mu = norm(QQ(:, i));
    
    disp([val, val(:, 1) ./ val(:, 2)]);
    disp(val * [lambda; mu]);
end
    

eqs_ = inf(size(eqs));
for i = 1:size(eqs, 1)
    vars = symvar(eqs(i));
    eqs_(i) = eval(subs(eqs(i), vars, vars));
end
fprintf('eqs evaluated to be less than %e\n', max(eqs_));

%% Solve

known_vars = setdiff(symvar(eqs), unknown_vars);
known = {};
for var = known_vars
    known = [known {char(var)}];
end
unknown = {};
for var = unknown_vars
    unknown = [unknown {char(var)}];
end

kngroups = [];

[res, export] = gbs_CreateCode('pc_3prast0', eqs, known, unknown, kngroups);

    
    
    