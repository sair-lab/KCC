function q = affparam2mat(p)

% Copyright (C) Jongwoo Lim and David Ross.  All rights reserved.


sz = size(p);
if (length(p(:)) == 6)
  p = p(:);
end
s = p(3,:);  th = p(4,:);  r = p(5,:);  phi = p(6,:);
cth = cos(th);  sth = sin(th);  cph = cos(phi);  sph = sin(phi);
ccc = cth.*cph.*cph;  ccs = cth.*cph.*sph;  css = cth.*sph.*sph;
scc = sth.*cph.*cph;  scs = sth.*cph.*sph;  sss = sth.*sph.*sph;
q(1,:) = p(1,:);  q(2,:) = p(2,:);
q(3,:) = s.*(ccc +scs +r.*(css -scs));  q(4,:) = s.*(r.*(ccs -scc) -ccs -sss);
q(5,:) = s.*(scc -ccs +r.*(ccs +sss));  q(6,:) = s.*(r.*(ccc +scs) -scs +css);
q = reshape(q, sz);
