function [f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = ResiliencyMILPForm(NODE,SECTION,DER,PARAM)
% N                 - NODE.ID
% S                 - (SECNTION.FROM,SECTION.TO)
% D                 - DER.ID
% w                 - NODE.w
% p                 - NODE.p
% q                 - NODE.q
% KVAmax_d          - DER.CAPACITY
% alpha             - 1
alpha = 1;
pf = 0.85;
M = 5;

N = length({NODE.ID});    % Number of Nodes
S = length({SECTION.ID}); % Number of Sections
D = length({DER.ID});     % Number of DER

%%
%     max             sum(w_i * sum(c_id*p_i))
% a,b,c,gamma,d       i<N       d<D

% Let x = [a;b;c;gamma;d], then
% a     = x[      1      :      n     ]
% b     = x[     n+1     :     n+s    ]
% c     = x[    n+s+1    :  (d+1)n+s  ]
% gamma = x[  (d+1)n+s+1 : (2d+1)n+s  ]
% d     = x[ (2d+1)n+s+1 : (2d+1)n+2s ]

% Define starting indicies
a = 0;
b = N;
c = N+S;
gamma = (D+1)*N+S;
d = (2*D+1)*N+S;

f_a     = zeros(N,1);
f_b     = zeros(S,1);
f_c     = -ones(N*D,1) + repmat(-[NODE.w]'.*[NODE.p]',D,1);
f_gamma = zeros(D*N,1);
f_d     = zeros(S,1);

f = [f_a;f_b;f_c;f_gamma;f_d];

xlen = length(f);

%% Set variable bounds/binary constraints
% All Variables are binary
lb = zeros(xlen,1);
ub = ones (xlen,1);
intcon = 1:xlen;

%%  Constraints
% -DSCC-(1)-to-(4)---------------------------------------------------------
% (1) Nodes constrained open      (a_i = 0 Vi<NO)       ---UNUSED---
% (2) Nodes constrained closed    (a_i = 1 Vi<NC)       ---FIX CP---
% (3) Sections constrained open   (b_ij = 0 V(i,j)<SO)  ---FAULTS---
% (4) Sections constrained closed (b_ij = 1 V(i,j)<SC)  ---NO SWI---

NO = length(PARAM.NO);
NC = length(PARAM.NC);
SO = length(PARAM.SO);
SC = length(PARAM.SC);

b1 = zeros(NO,1);
b2 = ones (NC,1);
b3 = zeros(SO,1);
b4 = ones (SC,1);

A1 = zeros(NO,xlen);
A2 = zeros(NC,xlen);
A3 = zeros(SO,xlen);
A4 = zeros(SC,xlen);

for i = 1:NO
    % Find index of constrained node
    index = find(ismember({NODE.ID},PARAM.NO{i}));
    
    A2(i,a+index) = 1; % coeff for a_i (1)
end

for i = 1:NC
    % Find index of constrained node
    index = find(ismember({NODE.ID},PARAM.NC{i}));
    
    A2(i,a+index) = 1; % coeff for a_i (2)
end

for i = 1:SO
    % Find index of constrained section
    index = find(ismember({SECTION.ID},PARAM.SO{i}));
    
    A4(i,b+index) = 1; % coeff for b_ij (3)
end

for i = 1:SC
    % Find index of constrained section
    index = find(ismember({SECTION.ID},PARAM.SC{i}));
    
    A4(i,b+index) = 1; % coeff for b_ij (4)
end
    
% -MCC-(6)-to-(8)----------------------------------------------------------
% (6)  c_id - gamma_id <= 0         all i in N, d in D
% (7)  c_id - a_i <= 0              all i in N, d in D
% (8) -c_id + gamma_id + a_i <= 1   all i in N, d in D

b6 = zeros(D*N,1);
b7 = zeros(D*N,1);
b8 = ones (D*N,1);

A6 = zeros(D*N,xlen);
A6(:,c+1:c+D*N) = eye(D*N); % coeff for c_id (6)
A7 = A6; % coeff for c_id (7)
A7(:,a+1:a+N) = repmat(-eye(N),D,1); % coeff for a_i (7)
A6(:,gamma+1:gamma+D*N) = -eye(D*N); % coeff for gamma_id (6)
A8 = -A6; % coeff for c_id, gamma_id (8)
A8(:,a+1:a+N) = repmat(eye(N),D,1); % coeff for a_i (8)

% -MCC-(9)-to-(11)--VDC-(13)-&-(14)----------------------------------------
% (9) sum(alpha s_i c_id) <= KVAmax_d  all d in D
%     i<N
% (10) sum(gamma_id) <= 1              all i in N
%      d<D
% (11) gamma_dd = 1                    all d in D
% (13) d_ij - b_ij <= 0                all (i,j) in S
% (14) d_dj - b_dj = 0                 all (d,j) in S, d in D
%      d_id = 0                        all (i,d) in S, d in D

% index = { id  dj }

b9 = [DER.CAPACITY]'; % CHECK TO SEE IF ORIENTED CORRECTLY
b10 = ones(N,1);
b11 = ones(D,1);
b13 = zeros(S,1);

A9 = zeros(D,xlen);

A10 = zeros(N,xlen);
A10(:,gamma+1:gamma+D*N) = repmat(eye(N),1,D); % coeff for gamma_id (10)

A11 = zeros(D,xlen);

A13 = zeros(S,xlen);
A13(:,d+1:d+S) = eye(S); % coeff for d_ij (13)
A13(:,b+1:b+S) = -eye(S); % coeff for b_ij (13)

A14 = zeros(1,xlen);

temp = alpha*[NODE.p]/pf;
j = 1;
for i = 1:D
    A9(i,c+(i-1)*N+1:c+i*N) = temp;  % coeff for c_id  all i in N, d constant (9)
    
    % Find node index of DER
    index = find(ismember({NODE.ID},DER(i).ID));
    
    A11(i,gamma+(i-1)*d+index) = 1;  % coeff for gamma_dd (11)
    
    % Find section index of all sections adjacent to DER
    index = {find(ismember({SECTION.FROM},DER(i).ID)),...
        find(ismember({SECTION.TO},DER(i).ID))};
    
    while ~isempty(index{1})
        A14(j,d+index{1}(1)) = 1; % coeff for d_dj (14.1)
        A14(j,b+index{1}(1)) = -1; % coeff for b_dj (14.1)
        index{1}(1) = [];
        
        j = j+1;
    end
    
    while ~isempty(index{2})
        A14(j,d+index{2}(1)) = 1; % coeff for d_id (14.2)
        index{2}(1) = [];
        
        j = j+1;
    end
end
clear temp

b14 = zeros(j-1,1);

% -MCC-(12)-----------------------------------------------------------------------
% (12) gamma_id - gamma_jd + b_ij <= 1    all (i,j) in S, d in D
%   -( gamma_id - gamma_jd ) + b_ij <= 1  all (i,j) in S, d in D

% index = [ FROM  ,  TO ]

% (19) sum(d_ki) +   sum(b_ik-d_ik) + sum(b_jk-d_jk) +   sum(d_kj) + M*b_ij <= M + 1  all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j       (j,k)<S          (k,j)<S,k\=i
% (22) sum(d_ki) +   sum(b_ik-d_ik) - d_ij + M*b_ij <= M                              all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j  
%   -( sum(d_ki) +   sum(b_ik-d_ik) - d_ij ) + M*b_ij <= M                            all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j  
% (23) sum(b_jk-d_jk) +   sum(d_kj) + d_ij + M*b_ij <= M + 1                          all (i,j) in S
%     (j,k)<S          (i,k)<S,k\=i
%   -( sum(b_jk-d_jk) +   sum(d_kj) + d_ij ) + b_ij <= 0                            all (i,j) in S
%     (j,k)<S          (i,k)<S,k\=i

% index = { ik  ki  jk  kj }

b12 = ones(2*D*S,1);
b19 = (M+1)*ones(S,1);
b22 = M*ones(2*S,1);
b23 = [(M+1)*ones(S,1);zeros(S,1)];

A12 = zeros(2*D*S,xlen);
A19 = zeros(S,xlen);
A22 = zeros(2*S,xlen);
A23 = zeros(2*S,xlen);

for k = 1:S % for each section (i,j)
    % Find index of FROM and TO nodes of section
    index = [find(ismember({NODE.ID},SECTION(k).FROM)),...
    find(ismember({NODE.ID},SECTION(k).TO))];
    
    A12(k+0:S:D*S,gamma+index(1)) = 1; % coeff for gamma_id (12.1)
    A12(k+0:S:D*S,gamma+index(2)) = -1; % coeff for gamma_jd (12.1)
    A12(k+D*S:S:2*D*S,:) = -A12(k+0:S:D*S,:); % coeff for gamma_id, gamma_jd (12.2)
    A12(k+0:S:2*D*S,b+k) = 1; % coeff for b_ij (12.1) (12.2)
    
    % Find Index of all adjacent sections
    index = {find(ismember({SECTION.FROM},SECTION(k).FROM)),...
    find(ismember({SECTION.TO},SECTION(k).FROM)),...
    find(ismember({SECTION.FROM},SECTION(k).TO)),...
    find(ismember({SECTION.TO},SECTION(k).TO))};
    % Remove section k from list of adjacent sections
    index{1}(index{1}==k) = [];
    index{4}(index{4}==k) = [];
    
    A19(k,d+[index{1},index{3}]) = -1; % coeff for d_ik, d_jk (19)
    A19(k,[b+[index{1},index{3}],d+[index{2},index{4}]]) = 1; % coeff for b_ik, d_ik, d_ki, d_kj (19)
    A19(k,b+k) = M; % coeff for b_ij (19)
    
    A22(k,[d+index{1},d+k]) = -1; % coeff for d_ik, d_ij (22.1)
    A22(k,[b+index{1},d+index{2}]) = 1; % coeff for b_ik, d_ki (22.1)
    A22(k+S,:) = -A22(k,:); % coeff for d_ik, d_ij, b_ik, d_ki (22.2)
    A22([k,k+S],b+k) = M; % coeff for b_ij (22.1) (22.2)
    
    A23(k,d+index{3}) = -1; % coeff for d_jk (23.1)
    A23(k,[b+index{3},d+index{4},d+k]) = 1; % coeff for b_jk, d_kj, d_ij (23.1)
    A23(k+S,:) = -A23(k,:); % coeff for d_jk, b_jk, d_kj, d_ij (23.2)
    A23([k,k+S],b+k) = 1; % coeff for b_ij (23.1) (23.2)
end

% Remove Constraints (22) and (23) from Sections with DER Attached
for i = 1:D
    index = [find(ismember({SECTION.FROM},DER(i).ID)),...
    find(ismember({SECTION.TO},DER(i).ID))];
    
    b22([index,index+S],:) = [];
    b23([index,index+S],:) = [];
    
    A22([index,index+S],:) = [];
    A23([index,index+S],:) = [];
end

% -------------------------------------------------------------------------

bb = zeros(D*(N-D),1);

AA = zeros(D*N,xlen);
AA(:,gamma+1:gamma+D*N) = eye(D*N);

for i = 1:N
    index = {find(ismember({SECTION.FROM},NODE(i).ID)),...
        find(ismember({SECTION.TO},NODE(i).ID))};
    
    AA(i+0:N:D*N,d+index{1}) = 1;
    AA(i+0:N:D*N,[b+index{1},d+index{2}]) = -1;
end

for i = 1:D
    index = find(ismember({NODE.ID},DER(i).ID));
    AA(index+0:N:D*N,:) = [];
end

Aineq = [A6;A7;A8;A9;A10;A12;A13;A19;A22;A23;AA];
bineq = [b6;b7;b8;b9;b10;b12;b13;b19;b22;b23;bb];

Aeq = [A1;A2;A3;A4;A11;A14];
beq = [b1;b2;b3;b4;b11;b14];