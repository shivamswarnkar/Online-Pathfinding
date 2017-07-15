%{
	Introduction:
	When you write a code to extract all the Northern neighbors
	of a box, you can be sure that this code is rather similar
	for extracting the Southern, Eastern, Western neighbors.
	We do not want to write 4 copies of this code!

	The following class is an aid for writing such code.
	It provides an "algebra" of indices, which amounts
	to algebraic manipulation of sign vectors.

	But we also want to exploit enum types so that our
	human intuitions about compass directions can be used.

	Indices for directions (N, S, E, W)
				i.e., (23, 21, 32, 12)
		and for children (NE, NW, SE, SW),
				i.e., (33, 13, 31, 11)
		and their algebra.

		NOTE: the indices are pairs of signs,
			where a sign is an element of {+1, 0, -1}.
			But in Matlab, we need to convert
			each pair into a integer value (int32),
			called its "code".

			E.g.,  [0,+1] is a direction index with code 23
			E.g.,  [+1,-1] is a child index with code 31

	
	HOW TO USE THIS CLASS:
		1.  You can use this to get "enum types"
	
			>> direction1 = Idx.N
			>> direction2 = Idx.W 
			>> child1 = Idx.NE
			>> child2 = Idx.SE

		2.  Methods "code(ii)" and "ind(cc)" will
			convert between a code cc and index ii.
				E.g., code(31) = SE
				E.g., code(32) = E
				E.g., ind(SE) = 31
				E.g., ind(E) = 32
		    Two related methods converts child/dir indices into
		    an integer between 1 and 4:

		    "quad(cc)" returns the corresponding
			quadrant (i.e., 1,2,3 or 4) of a child index.
				E.g., quad(NE) = 1
		    "dir(dd)" returns 1,2,3 or 4:
		    		E.g. dir(N) = 1
		    		E.g. dir(W) = 2
		    		E.g. dir(S) = 3
		    		E.g. dir(E) = 4

		3.  Methods dirs() and children() returns an array
			of directions (N,S,E,W) or
			of child indices (NE, NW, SW, SE).
			This is useful for interations.

		4.  Method "opp(dir)" returns the opposite direction.
				E.g., opp(N) = S.

		5.  Method "adj(dir)" returns a pair of child that are
				adjacent in direction dir.
				E.g., adj(N) = [SE, SW].

		6.  Method "nbr(chil, dir)" returns a child index
			that can be used for maintaining
			principal neighbors.
				E.g., nbr(NE,N) = SE.
				E.g., nbr(NE,S) = SE.
				E.g., nbr(NE,E) = NW.
				E.g., nbr(NE,W) = NW.
			
		    Related Method "isSibling(chil, dir)" returns true iff
		    the principal neighbor of box.child(chil).pNbrs(dir)
		    is a sibling of box.child(chil).
				E.g., isSibling(NE,N) = 0.
				E.g., isSibling(NE,S) = 1.
				E.g., isSibling(NE,E) = 0.
				E.g., isSibling(NE,W) = 1.

		7.  Method "str(ind)" will return the string
				corresponding to the index ind.
				E.g., str(33) = 'NE'.

		NOTE:
		   (a) We use "chil" instead of "child" because the class
			Box1 has a property called "child".
		   (b) We generally use the code (int32) rather
		   	than the index for arguments and return values.
	
	Intro Robotics (Spring 2017)
	--Chee Yap (Apr 1, 2017)
%}

classdef Idx < int32
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    enumeration
        NE	(33)		% = [+1,+1]
        NW	(13)		% = [-1,+1]
        SE	(31)		% = [+1,-1]
        SW	(11)		% = [-1,-1]
    end

    enumeration
        N	(23)		% = [0,+1]
        W	(12)		% = [-1,0]
        S	(21)		% = [0,-1]
        E	(32)		% = [+1,0]
	end
	
	methods (Static = true)
	
		% dirs()
		%	returns an array of the direction indices
		%	This is useful for iterations over all directions. 
		function d = dirs()
			d (1) = Idx.N;
			d (2) = Idx.W;
			d (3) = Idx.S;
			d (4) = Idx.E;
		end
	
		% children()
		%	returns an array of the children indices.
		%	This is useful for iterations over all children. 
		function d = children()
			d (1) = Idx.NE;
			d (2) = Idx.NW;
			d (3) = Idx.SW;
			d (4) = Idx.SE;
		end
	
		% quad(c)
		% 	-- converts a code c into the quadrant number
		%	e.g., quad(NE) returns 1
		%	e.g., quad(SW) returns 3
		function i = quad(c)
			i = 0;
			switch c
			case 33  % NE
			    i=1; 
			case 13  % NW
			    i=2;
			case 11  % SW
			    i=3; 
			case 31  % SE
			    i=4;
			end
		end

		% dir(d)
		% 	-- converts a direct
		%	e.g., dir(N) returns 1
		%	e.g., dir(S) returns 3
		function i = dir(c)
			i = 0;
			switch c
			case 23  % N
			    i=1; 
			case 12  % W
			    i=2;
			case 21  % S
			    i=3; 
			case 32  % E
			    i=4;
			end
		end
	
		% ind(c)
		% 	-- converts a code c into an ind:
		%	e.g., ind(12) returns [-1, 0] (=W)
		%   e.g., ind(13) returns [-1,+1] (=NW)
		function ind = ind(c)
			cc = int32(c);
			ind(1) = idivide(cc, int32(10)) - 2;
			ind(2) = mod(cc, 10) - 2;
		end
	
		% code(ind)
		% 	-- converts an index "ind" to a code c
		%	e.g., code([0,-1]) returns 21 (="south")
		function cc = code(ind)
			cc = int32((ind(1)+2)*10 + (ind(2) +2));
        end
            

		% code2(indx, indy)
		% 	-- variation of code(ind) where we are given 2 ints
		%	e.g., code(0,-1) returns 21 (="south")
		function cc = code2(indx, indy)
			cc = int32((indx +2)*10 + (indy +2));
		end
	
		% opp(dir)
		%	-- transforms direction "dir" to its opposite direction
		%		e.g., opp(N) returns S
		%		e.g., opp(S) returns N
		%		e.g., opp(E) returns W
		%	-- Actually, it also works for child indices!
		%		e.g., opp(NE) returns SW
		%		e.g., opp(SW) returns NE
		function dd = opp(dir)
			ii = Idx.ind(dir);
			dd = Idx.code(-ii);
		end
	
		% adj(dir)
		%	-- returns a pair of siblings that are adjacent
		%		in the direction "dir"
		%	e.g., adj(N) returns [SE SW]
		%	e.g., adj(W) returns [NE SE]
		%	e.g., adj(S) returns [NE NW]
		%	e.g., adj(E) returns [NW SW]
		function pair = adj(dir)
			ii = - Idx.ind(dir);	% negation of dir
			i1 = ii;
			i2 = ii;
			i1(ii == 0) = int32(1);
			i2(ii == 0) = int32(-1);
			pair = [Idx.code(i1), Idx.code(i2)];
		end
	
		
		% isSibling(chil,dir)
		%		returns true iff 
		%   	the principal neighbor of box.child(chil).pNbrs(dir)
		%   	is a sibling of box.child(chil).
		%	E.g., isSibling(NE,N) = 0.
		%	E.g., isSibling(NE,S) = 1.
		%	E.g., isSibling(NE,E) = 0.
		%	E.g., isSibling(NE,W) = 1.
		%
		% We define 
		%	isCompatible(chil, dir) to be the
		% complement of 
		%	isSibling(chil, dir).
		%
		function flag = isCompatible(chil, dir)
			cc = Idx.ind(chil);
			dd = Idx.ind(dir);
			c = cc(dd ~=0);
			d = dd(dd ~=0);
			flag = 	(c == d);
	    end

		function flag = isSibling(chil, dir)
			flag = 	~Idx.isCompatible(chil,dir);
	    end
	
		% nbr(chil,dir)
		%	-- returns a child index such that
		%		the principal nbr of chil can point to!
		%
		% 	HOW TO USE "nbr"?  There are 2 cases
		%
		%	  CASE 1: compatible(chil,dir) is true
		%		-- E.g., nbr(NE, N) returns SE
		%			This means 
		%		  box.child(NE).N = (box.N).child(SE)
		%		-- thus the principal nbr is a "cousin"
		%
		%	  CASE 2: compatible(chil,dir) is false
		%	-- E.g., nbr(NE, W) = NW
		%			means that
		%		box.child(NE).W =box.child(NW)
		%		-- thus the principal nbr is a "sibling"
		%
		%	REMARK: these 2 cases are arise ONLY in applications
		%		to the problem of maintaining principle
		%		nbrs.  Our code here makes no distinction!
		function c = nbr(chil, dir)
			dd = Idx.ind(dir);
			cc = Idx.ind(chil);
			cc(dd ~= 0) = - cc(dd ~= 0);	% flip the sign!
			c = Idx.code(cc);
		end

		% str(ind) -- returns a string
		%	str(33)='NE'
		function s = str(ind)
			switch ind
			    case 33
				s = 'NE';
			    case 13
				s = 'NW';
			    case 31
				s = 'SE';
			    case 11
				s = 'SW';
			    case 23
				s = 'N';
			    case 21
				s = 'S';
			    case 32
				s = 'E';
			    case 12
				s = 'W';
			end
		end


		% test()
		%
		function ccc = test()
			disp(['Testing nbr(chil, dir):']);
			for c = Idx.children()
			    for d = Idx.dirs()
                    disp(['nbr(', Idx.str(c), ', '...
				          Idx.str(d), ')=',...
				          Idx.str(Idx.nbr(c,d))...
						]);
			    end
			end
	    end
    end
end