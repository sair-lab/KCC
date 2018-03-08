function q = affparam2geom(p)

% Copyright (C) Jongwoo Lim and David Ross.  All rights reserved.

A = [ p(3), p(4); p(5), p(6) ];

[U,S,V] = svd(A);
if (det(U) < 0)
  U = U(:,2:-1:1);  V = V(:,2:-1:1);  S = S(2:-1:1,2:-1:1);
end


q(1) = p(1);  
q(2) = p(2);  


q(4) = atan2(U(2,1)*V(1,1)+U(2,2)*V(1,2), U(1,1)*V(1,1)+U(1,2)*V(1,2));

phi = atan2(V(1,2),V(1,1));
if (phi <= -pi/2)
  c = cos(-pi/2); s = sin(-pi/2);
  R = [c -s; s c];  V = V * R;  S = R'*S*R;
end
if (phi >= pi/2)
  c = cos(pi/2); s = sin(pi/2);
  R = [c -s; s c];  V = V * R;  S = R'*S*R;
end


q(3) = S(1,1);
q(5) = S(2,2)/S(1,1);

q(6) = atan2(V(1,2),V(1,1));

q = reshape(q, size(p));
