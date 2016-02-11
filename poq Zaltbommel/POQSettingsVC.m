//
//  POQSettingsVC.m
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 01/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQSettingsVC.h"

@interface POQSettingsVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblValueSliderUitgaand;
@property (weak, nonatomic) IBOutlet UILabel *lblValueSliderInkomend;
- (IBAction)sliderUitgaand:(id)sender;
- (IBAction)sliderInkomend:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *sliderIn;
@property (weak, nonatomic) IBOutlet UISlider *sliderUit;


@end

@implementation POQSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Klaar" style: UIBarButtonItemStylePlain
                                             target:self action:@selector(dismissMyView)];

    self.lblValueSliderUitgaand.text = [NSString stringWithFormat:@"%.0f km.", [self.sliderUit value]];

    self.lblValueSliderInkomend.text = [NSString stringWithFormat:@"%f km.", [self.sliderIn value]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dismissMyView {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sliderUitgaand:(id)sender {
    self.lblValueSliderUitgaand.text = [NSString stringWithFormat:@"%f km.", [(UISlider *)sender value]];
}

- (IBAction)sliderInkomend:(id)sender {
    self.lblValueSliderInkomend.text = [NSString stringWithFormat:@"%f km.", [(UISlider *)sender value]];
}
@end
