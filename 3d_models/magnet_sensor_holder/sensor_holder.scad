//----------------------------------------------------
// ------------ Parameters ------------ 
//----------------------------------------------------
chip_x = 10;
chip_y = 12;
chip_h = 2.5;

holder_hole_d = 29/2;
holder_hole_r = 1.6;

holder_y = chip_y+4;
holder_x = 2*(holder_hole_d+2*holder_hole_r)+1;
holder_h = 6.3;

sensor_board_hole_d=20.3/2;
sensor_board_hole_r=1;
sensor_board_x=2*(holder_hole_d-holder_hole_r)-1.5;
sensor_board_y=sensor_board_x;

//----------------------------------------------------
// ------------ Modelling ------------ 
//----------------------------------------------------

rotate([180,0,0]) {
    difference(){
        linear_extrude(holder_h, center=false)
            square([holder_x, holder_y], center=true);
        // Hole holder 1
        translate([holder_hole_d,0.0])
            cylinder(h=holder_h,r=holder_hole_r,center=false,$fn=50);
        translate([holder_hole_d,0,holder_h-1.75])
            cylinder(h=1.75,r1=3.2/2,r2=6.1/2,$fn=50);
        // Hole holder 2
        translate([-holder_hole_d,0.0])
            cylinder(h=holder_h,r=holder_hole_r,center=false,$fn=50);
        translate([-holder_hole_d,0,holder_h-1.75])
            cylinder(h=1.75,r1=3.2/2,r2=6.1/2,$fn=50);
        
        // Chip
        linear_extrude(holder_h, center=false)
            square([chip_x, chip_y], center=true);
        // Hole sensor 1
        translate([sensor_board_hole_d,0.0])
            cylinder(h=holder_h,r=sensor_board_hole_r,center=false,$fn=50);
        // Hole sensor 2
        translate([-sensor_board_hole_d,0.0])
            cylinder(h=holder_h,r=sensor_board_hole_r,center=false,$fn=50);
        linear_extrude(4.3, center=false)
            square([sensor_board_x, sensor_board_y], center=true);
    }
}