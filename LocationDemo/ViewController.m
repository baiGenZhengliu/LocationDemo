//
//  ViewController.m
//  location
//
//  Created by HuJiazhou on 16/7/12.
//  Copyright © 2016年 HuJiazhou. All rights reserved.
//

#import "ViewController.h"

#import <CoreLocation/CoreLocation.h>



@interface ViewController ()<CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSNumber *longitute;

@property (nonatomic,strong) NSNumber *latitude;
@property (weak, nonatomic) IBOutlet UITextField *country;

@property (weak, nonatomic) IBOutlet UITextField *province;

@property (weak, nonatomic) IBOutlet UITextField *city;

@property (weak, nonatomic) IBOutlet UITextField *street;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startLocating];
    
//    [self getLongitudeAndLatitudeWithCity:@"上海"];
}


#pragma mark - delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Longitude = %f", manager.location.coordinate.longitude);
    NSLog(@"Latitude = %f", manager.location.coordinate.latitude);
//    [self.locationManager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    NSLog(@"newLocation:%@\noldLocation:%@",newLocation,oldLocation);
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSLog(@"%@",placemarks);
        
        for (CLPlacemark * placemark in placemarks) {
            NSDictionary *test = [placemark addressDictionary];
            //  Country(国家)  State(城市)  SubLocality(区)
            NSLog(@"%@", [test objectForKey:@"Country"]);
            NSLog(@"%@", [test objectForKey:@"State"]);
            NSLog(@"%@", [test objectForKey:@"SubLocality"]);
            NSLog(@"%@", [test objectForKey:@"Street"]);
            
            self.country.text = [test objectForKey:@"Country"];
            self.province.text = [test objectForKey:@"State"];
            self.city.text = [test objectForKey:@"SubLocality"];
            self.street.text = [test objectForKey:@"Street"];

        }
    }];
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

#pragma mark - 1.定位方法
- (void)startLocating{
    
    if([CLLocationManager locationServicesEnabled]){
        
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter=10;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0){
            [self.locationManager requestAlwaysAuthorization];
            //        [self.locationManager requestWhenInUseAuthorization];
        }
        //开始实时定位
        [self.locationManager startUpdatingLocation];
    }
}


#pragma mark - 2.获取某地的经纬度
// 获取某一地点的经纬度
- (void)getLongitudeAndLatitudeWithCity:(NSString *)city
{
    //city可以为中文
    NSString *oreillyAddress = city;
    CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
    [myGeocoder geocodeAddressString:oreillyAddress completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil){
            
            NSLog(@"Found %lu placemark(s).", (unsigned long)[placemarks count]);
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            NSLog(@"Longitude = %f", firstPlacemark.location.coordinate.longitude);
            NSLog(@"Latitude = %f", firstPlacemark.location.coordinate.latitude);
        }
        else if ([placemarks count] == 0 && error == nil){
            
            NSLog(@"Found no placemarks.");
        }
        else if (error != nil){
            
            NSLog(@"An error occurred = %@", error);
        }
    }];
}

#pragma mark - 3.计算两地的距离
// 计算两个地点的距离
- (double)distanceByLongitude:(double)longitude1 latitude:(double)latitude1 longitude:(double)longitude2 latitude:(double)latitude2{
    CLLocation* curLocation = [[CLLocation alloc] initWithLatitude:latitude1 longitude:longitude1];
    CLLocation* otherLocation = [[CLLocation alloc] initWithLatitude:latitude2 longitude:longitude2];
    double distance  = [curLocation distanceFromLocation:otherLocation];//单位是m
    return distance;
}




@end














