// Import a library with models of metric nuts
include <cyl_head_bolt.scad>;

//----------------------------------------------------
// ------------ Parameters ------------ 
//----------------------------------------------------
R = 1.5; // radius of the o-ring core
r2 = 204/2; // inner radius of the hoop (from center of the hoop to the center of the o ring profile)
r3 = 84/2+R+1.5; // outter radius of the inner hoop 
h1 = 4; // height of the base of the hoop
h2 = 8; // distance from the base to the center of the o-ring profile
h3 = 14.7; // distance between the o-rings (center to center)
h4 = 2.5; //distance from the outter o-ring to the outter edge of the hoop

ushape_oRings_dist = 11; // distance between the center of the inner and outer o-ring on the ushape inner hoop
ushape_R = 50;

h_tot = h1+h2+h3+h4;
R_ext = 0.25;
r_r = 2
; // depth of the rim
r1 = r2+2*R+2+5; // outter radius of the hoop

r_in = 27.5;

echo("Outter diameter of the hoop is: ", 2*r1);
echo("Outter diameter of the inner hoop is: ", 2*r3);
echo("Inner diameter of the outer hoop is: ", 2*(r2+R-dy));
echo("Diameter of the inner part of the inner ushape (to the center of the o-ring)", 2*(ushape_R-ushape_oRings_dist/2));
echo("Diameter of the outer part of the inner ushape (to the center of the o-ring)", 2*(ushape_R+ushape_oRings_dist/2));

d_nevim = 0.5;
h_nevim = 0.5;

d_rib = 16;

//d_tooth = 0.1231;
d_tooth = 0.25;

alpha = 55;
beta = 25;
gamma = 50;

// Calculate some values for a bit (not much actually) more clear calculations in the following script 
hx = h1+h2+R*sin(alpha);
dx = r1-r2-R*(1+cos(alpha));
hy = h2-(R+R_ext)*sin(beta);
dy = (R+R_ext)*cos(beta);

hz = r_r*tan(gamma);

r_groove = r1-dx-sqrt(d_nevim*d_nevim/2)+r_r; //thickness of the wall between the outter side of the large hoop and the bottom of the groove

part1_height = hx;
part2_height = 2*(h3/2+h2+h1-hx);
part3_height = h1+h2+h3+h4 - part1_height - part2_height;


//----------------------------------------------------
// ------------ Modelling ------------ 
//----------------------------------------------------
// outter o-rings
module outter_oring_lower() {
    translate([r2+R,h1+h2,0]){
        circle(R, $fn=50);
    };
};
module outter_oring_upper() {
    translate([0,h3,0]){
        outter_oring_lower();
    };
};

// Mounting holes
module mounting_hole_m3_tall(){
    cylinder(h=h1+h2+h3+h4+1, r=1.6, center=false,,$fn=50);
}
module mounting_hole_m3(){
    cylinder(h=h1+h2+h3+h4, r=1.6, center=false,,$fn=50);
}

// ------------ outter hoop (the larger one) ------------ 

//// Profiles of the parts of the outter hoop
// Profile 1 - the bottom one
//      before the subtraction of the o-rings
module profile_part01() {
    polygon(points=[[r2+R-dy,0],[r1,0],[r1,hx],[r1-dx,hx], [r2+R,h1+h2],[r2+R-dy,h1+hy],[r2+R-dy,h1]]);
};

// model of the tooth biting into the oring (parameter d_tooth)
module profile_part01_tooth() {
    polygon(points=[[r2+R-R*cos(beta),h1+h2-R*sin(beta)],[r2+R-R*cos(beta)+d_tooth,h1+h2-R*sin(beta)],[r2+R-R*cos(beta)+d_tooth,h1+h2-R],[r2+R-R*cos(beta),h1+h2-R]]);
}

//      after the subtraction of the o-ring
module profile_part1() {
    union() {
        difference() {
            profile_part01();
            outter_oring_lower();
        };
        profile_part01_tooth();
    }
};

// Profile 2 - the middle one
module profile_part2_half() {
    polygon(points=[[r1,hx], [r1-dx,hx], [r1-dx-sqrt(d_nevim*d_nevim/2),hx+sqrt(d_nevim*d_nevim/2)],[r1-dx-sqrt(d_nevim*d_nevim/2),hx+sqrt(d_nevim*d_nevim/2)+h_nevim], [r_groove, hx+sqrt(d_nevim*d_nevim/2)+h_nevim+hz],[r_groove, h1+h2+h3/2],[r1,h1+h2+h3/2]]);
};
module profile_part2() {
    union(){
        profile_part2_half();
        translate([0,2*(h1+h2+h3/2),0]) {
            mirror([0,1,0]){
                color("Cyan") profile_part2_half();
            };
        };
    };
};

// Profile 3 - the bottom one
//      before the subtraction of the o-rings
module profile_part03() {
    polygon(points=[[r1,h1+h2+h3-R*sin(alpha)],[r1-dx,h1+h2+h3-R*sin(alpha)], [r2+R,h1+h2+h3], [r2+R-dy,h1+h2+h3+(R+R_ext)*sin(beta)], [r2+R-dy,h1+h2+h3+h4], [r1,h1+h2+h3+h4]]);
};

// model of the tooth biting into the oring (parameter d_tooth)
module profile_part03_tooth() {
    polygon(points=[[r2+R-R*cos(beta),h1+h2+h3+R*sin(beta)],[r2+R-R*cos(beta)+d_tooth,h1+h2+h3+R*sin(beta)],[r2+R-R*cos(beta)+d_tooth,h1+h2+h3+R],[r2+R-R*cos(beta),h1+h2+h3+R]]);
}

//      after the subtraction of the o-ring
module profile_part3() {
    union() {
        difference() {
            profile_part03();
            outter_oring_upper();
        }
        profile_part03_tooth();
    }
};


//// Go to 3D
// Outter mounting holes
module outter_mounting_holes() {
    for (i=[1:12]) {
        rotate([0,0,i*30])
            translate([0,r1-(r1-r_groove)/2+0.3,0])
                mounting_hole_m3_tall();
    };
};

// Revolve the profiles and subtract the outter mounting holes
module part1(){
    union() {
        difference(){
            rotate_extrude($fn = 360){
                profile_part1();
            };
//            outter_mounting_holes();
        };
        base();
    };
};

module part2(){
    difference(){
        rotate_extrude($fn = 360){
            profile_part2();
        };
//        outter_mounting_holes();
    }
};

module part3(){
    difference(){
        rotate_extrude($fn = 360){
            profile_part3();
        };
//        outter_mounting_holes();
    }
};

//// Test parts
module part1_test(revolve_angle){
    union() {
        difference(){
            rotate(90-revolve_angle/2) {
                rotate_extrude(angle=revolve_angle, $fn = 360){
                    profile_part1();
                };
            }
            outter_mounting_holes();
        };
    };
};

module part2_test(revolve_angle){
    difference(){
        rotate(90-revolve_angle/2) {
            rotate_extrude(angle=revolve_angle, $fn = 360){
                profile_part2();
            };
        }
        outter_mounting_holes();
    }
};

module part3_test(revolve_angle){
    difference(){
        rotate(90-revolve_angle/2) {
            rotate_extrude(angle=revolve_angle, $fn = 360){
                profile_part3();
            };
        }
        outter_mounting_holes();
    }
};

// ------------ The base ------------ 
// inner mounting holes
module inner_mounting_holes(){
    for (i=[1:6]) {
        rotate([0,0,i*60])
            translate([0,ushape_R,0]) {
                mounting_hole_m3();
                scale(1.05)
                    translate([0,0,2])
                        nut("M3");
            };
    }

    // Bldc mounting holes - old gimbal motor
//    for (i=[1:4]) {
//        rotate([0,0,i*90])
//            translate([0, 25/2,0])
//                mounting_hole_m3();
//        rotate([0,0,i*90+45])
//            translate([0, 30/2,0])
//                mounting_hole_m3();
//    }
    
    // Bldc mounting holes - new ODrive motor
    for (i=[1:4]) {
        rotate([0,0,i*90+45])
            translate([0, 20/2,0])
                mounting_hole_m3();
    }
    
    cylinder(h=h1+1, r=7.2, center=false,,$fn=50);
}


module inner_circle_small(height) {
    cylinder(h=height, r=r_in, center=false,,$fn=180);
}

module inner_circle_large(height) {
    cylinder(h=height, r=r2+R-dy+1, center=false,,$fn=180);
}


// Ribs joining the outter hoop to the inner circle
// Model one rib
module bottom_planar_rib() {
    translate([r_in-d_rib,0,0]){
        square([d_rib,(r2+R-dy)],false);
    };
};

// copy and rotate it four times to get half of the total ribs
module bottom_planar_4ribs() {
    for (i=[1:4]) {
        rotate([0,0,i*90])
            bottom_planar_rib();
    }
};

// mirror the four ribs to get the remaining four
module bottom_8ribs(){
    bottom_planar_4ribs();
    mirror([1,0,0]){
        bottom_planar_4ribs();
    };
};

// extrude all the eight ribs and take the intersetion of the extruded ribs with the larger inner circle (full base)
module ribs(h) {
    intersection(){
        linear_extrude(height = h) {
            bottom_8ribs();
        };
        inner_circle_large(h);
    };
};

module inner_mounting_circle() {
    linear_extrude(height = h1)
        difference() {
            circle(r=ushape_R+dy+ushape_oRings_dist/2, $fn=200);
            circle(r=ushape_R-dy-ushape_oRings_dist/2, $fn=200);
        }
}

// Model the base - take union of the ribs, inner circle and subtract the inner mounting holes
module base() {
    difference(){
        union(){
            ribs(h1);
            inner_circle_small(h1);
            inner_mounting_circle();
        }
        inner_mounting_holes();
    };
}

//----------------------------------------------------
// ------------------- Inner hoop  ------------------- 
//----------------------------------------------------
module profile_part01_inner() {
    translate([-r1+r2+r3,0,0])
        mirror([1,0,0])
            translate([-r1,0,0]) {
                difference(){
                    profile_part1();
                    polygon(points=[[r2+R-dy-0.1,-0.1],[r1+0.1,-0.1],[r1,h1],[r2+R-dy,h1]]);
                }
            }
};


module profile_part02_inner() {
    translate([-r1+r2+r3,0,0])
        mirror([1,0,0])
            translate([-r1,0,0]) {
                profile_part2();
            }
};

module profile_part03_inner() {
    translate([-r1+r2+r3,0,0])
        mirror([1,0,0])
            translate([-r1,0,0]) {
                profile_part3();
            }
};

//inner hoop mounting pillar
module inner_hoop_pillar(height, length=7, width=6.4, countersunk=false) {
    translate([0,47/2,0]) {
        difference() {
            union() {
                translate([0,0,h1])
                    cylinder(h=height, r=width/2, center=false, $fn=50);
                translate([-width/2,0,h1])
                    cube([width,width+length,height], center=false);
            }
            mounting_hole_m3();
            if(countersunk) {
                translate([0,0,height+h1-1.6])
                    cylinder(h=1.6,r1=1.6,r2=2.8, center=false, $fn=50);
            }        
        }

    }
}

// inner mounting holes
module inner_hoop_pillars(height, length=7, width=6.4, number=6, countersunk=false){
    for (i=[1:number]) {
        rotate([0,0,i*60])
            inner_hoop_pillar(height, length, width, countersunk);
    }
}	

module inner_hoop_part1() {
	union() {
		rotate_extrude($fn = 200)
	            profile_part01_inner();
	    inner_hoop_pillars(hx-h1);
	}
}
module inner_hoop_part2() {
	union() {
		rotate_extrude($fn = 200)
		            profile_part02_inner();
		translate([0,0,hx-h1])
			inner_hoop_pillars(part2_height);
		}
}
module inner_hoop_part3() {
	union() {
		rotate_extrude($fn = 200)
		            profile_part03_inner();
		translate([0,0,hx-h1+part2_height])
			inner_hoop_pillars(part3_height);
	}
}

module backBlackSheet() {
    difference() {
        circle(r=r1, center=true, $fn=200);
        
//        // outer holes
//        for (i=[1:12]) {
//            rotate([0,0,i*30])
//                translate([0,r1-(r1-r_groove)/2+0.3,0])
//                    circle(r=1.5, center=true, $fn=200);
//        }
        
        for (i=[1:6]) {
            rotate([0,0,i*60])
                translate([0,ushape_R,0]) {
                    circle(r=3, center=true, $fn=200);
                };
        }

//        // Bldc mounting holes
//        for (i=[1:4]) {
//            rotate([0,0,i*90])
//                translate([0, 25/2,0])
//                    circle(r=1.5, center=true, $fn=200);
//            rotate([0,0,i*90+45])
//                translate([0, 30/2,0])
//                    circle(r=1.5, center=true, $fn=200);
//        }
        
    // Bldc mounting holes - new ODrive motor
    for (i=[1:4]) {
        rotate([0,0,i*90+45])
            translate([0, 20/2,0])
                circle(r=1.5, center=true, $fn=200);
    }
    
    circle(r=7.5, center=false,,$fn=50);
    
    }
}

//----------------------------------------------------
// --------------- U-shape inner hoop  ---------------
//----------------------------------------------------


// ------------ Debug outputs ------------ 
//color("Cyan")
//rotate_extrude($fn = 50)
//            profile_part1();
//color("Blue")
//rotate_extrude($fn = 50)
//            profile_part2();
//color("Cyan")
//rotate_extrude($fn = 50)
//            profile_part3();
//
//color("Red"){
//    rotate_extrude($fn = 50)
//    {
//        outter_oring_lower();
//        outter_oring_upper();
//    }
//};
//
//base();

//union(){
//    part1();
//    part2();
//    part3();
//};

// profile_part01_inner();
// profile_part02_inner();
// profile_part03_inner();

//---------------
    
// ------------
// linear_extrude(1){
// difference() {
//     circle(27, $fn=50);
//     for (i=[1:6]) {
//         rotate([0,0,i*60])
//             translate([0,47/2,0]) {
//                 circle(1.6, $fn=50);
//             };
//     }

//     // Bldc mounting holes
//     for (i=[1:4]) {
//         rotate([0,0,i*90])
//             translate([0, 25/2,0])
//                 circle(1.6, $fn=50);
//         rotate([0,0,i*90+45])
//             translate([0, 30/2,0])
//                 circle(1.6, $fn=50);
//     }
//     circle(5.5, $fn=50);
// }
// }
// ------------ test parts ------------ 
//test_rev_angle = 15;
//part1_test(test_rev_angle);
//part2_test(test_rev_angle);
//part3_test(test_rev_angle);

//profile_part01_ushape();
//profile_part02_ushape();
//profile_part03_ushape();

module profile_outer() {
    profile_part1();
    profile_part2();
    profile_part3();
}

module half_profile_ushape() {
    translate([0,0,0])
    difference(){
        translate([-r2-R,0,0]){
            profile_outer();
        }
        translate([ushape_oRings_dist/2,0,0])
            square([30, 30]);
        translate([-30,0,0])
            square([60, h1]);
    }
}

module profile_ushape() {
    union() {
        translate([-ushape_oRings_dist/2,0,0])
            half_profile_ushape();
        mirror([1,0,0])
            translate([-ushape_oRings_dist/2,0,0])
                half_profile_ushape();
    }
}

//half_profile_ushape();
module ushape(rrr, angl=270) {
    difference() {
        rotate([0,0,135]) {
            // The main body
            rotate_extrude(angle=angl, $fn=200)
                translate([rrr, 0, 0])
                    profile_ushape();
            
            // Endings
            translate([rrr,0,0])
                rotate_extrude($fn = 200, angle=180) {
                    translate([-ushape_oRings_dist/2,0,0])
                        half_profile_ushape();
                }    
            
            rotate([0,0,angl])
                translate([rrr,0,0])
                    rotate([0,0,180])
                    rotate_extrude($fn = 200, angle=180) {
                        translate([-ushape_oRings_dist/2,0,0])
                            half_profile_ushape();
                    }
        }
        
        inner_mounting_holes();
    }
}


//            circle(r=ushape_R+r1-r2+R-ushape_oRings_dist/2, $fn=200);



            
// ------------ final outputs ------------ 
//part1();
//part2();
//part3();


//ushape(ushape_R, 270);

//inner_hoop_part1();
//inner_hoop_part2();
//inner_hoop_part3();

backBlackSheet();

//rotate([180,0,0])
