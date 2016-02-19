//
//  NewGroupViewController.m
//  IMReasonable
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "NewGroupViewController.h"
#import "GroupPhotoTableViewCell.h"
#import "GroupSubTitleTableViewCell.h"
#import "GroupAddUserUIViewController.h"

@interface NewGroupViewController ()
{
    UIImage * img;
    NSString * subject;
}

@end

@implementation NewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initControl];
    [self initNav];

   

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) initNav
{
    //self.nav.title=@"创建群组";//NSLocalizedString(@"lbFphone", nil);
   // self.next.title=@"下一步";
    
    self.navigationItem.title=NSLocalizedString(@"lbfaCreatgroup", nil);//lbfaCreatgroup
    UIBarButtonItem * right=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"lbngvnext", nil) style:(UIBarButtonItemStyleBordered) target:self action:@selector(GoNext:)];
    
    UIBarButtonItem * left=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(GoBack:)];
    
    self.navigationItem.rightBarButtonItem=right;
    self.navigationItem.leftBarButtonItem=left;

}
- (void) initControl
{
    
    self.tableview.backgroundColor=[UIColor whiteColor];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row]==0) {
        return 65;
    }else{
        return 44;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    switch ([indexPath row]) {
        case 0:
        {
            GroupPhotoTableViewCell *   tempcell =[[GroupPhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupPhotoTableViewCell"];
        
            [tempcell.groupSelectPhoto addTarget:self action:@selector(SelectPhoto:) forControlEvents:UIControlEventTouchUpInside];
            //添加相片的按钮
            [tempcell.groupSelectPhoto setTitle:NSLocalizedString(@"lbngvaddphoto", nil) forState:UIControlStateNormal];
            [tempcell.groupSelectPhoto setTitle:NSLocalizedString(@"lbngvaddphoto", nil) forState:UIControlStateNormal];
            
            //设置提示
           [tempcell.msgTitle setText:NSLocalizedString(@"lbngvmsgtitle", nil)];
            tempcell.groupphoto.tag=8;
            
            
            
            cell=tempcell;
            
            
        }
            break;
        case 1:
        {
              GroupSubTitleTableViewCell*   tempcell =[[GroupSubTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupPhotoTableViewCell"];
            tempcell.subtitle.delegate=(id)self;
            tempcell.chanumber.tag=9;
            tempcell.subtitle.tag=99;
            
           // [tempcell.subtitle setText:NSLocalizedString(@"lbngvsubtitle", nil)];
            [tempcell.subtitle setPlaceholder:NSLocalizedString(@"lbngvsubtitle", nil)];
            
            //[tempcell.subtitle setTextColor:[UIColor grayColor]];
          //  txt=tempcell.
            
            cell=tempcell;
        
        
            
        }
            
            break;
   
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    return cell;
    
}
-(void)viewDidLayoutSubviews
{
    //去除分割线左边出现的空格
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}
- (void)SelectPhoto:(UIButton*)btn
{
    [self imagefromwhere];

}

- (void) imagefromwhere
{
    UIActionSheet * action;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        action  =  [[UIActionSheet alloc]initWithTitle:nil delegate:(id)self cancelButtonTitle: NSLocalizedString(@"lbTCancle",nil) destructiveButtonTitle:NSLocalizedString(@"lbngvdeleteimage",nil) otherButtonTitles:NSLocalizedString(@"lbTPhonto",nil),NSLocalizedString(@"lbTShoot",nil), nil];
    }
    else
    {
        //lbngvdeleteimage
        action =  [[UIActionSheet alloc]initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle" ,nil) destructiveButtonTitle:NSLocalizedString(@"lbngvdeleteimage",nil) otherButtonTitles:NSLocalizedString(@"lbTPhonto",nil), nil];
    }
    
    action.tag = 255;
    action.actionSheetStyle=UIActionSheetStyleAutomatic;
    [action showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            //相册
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            GroupPhotoTableViewCell * tempcell=(GroupPhotoTableViewCell*)[self.tableview cellForRowAtIndexPath:indexPath];
            UIImageView *chanumber;
            for (UIView *view in tempcell.contentView.subviews) {
                if (view.tag==8) {
                    chanumber =(UIImageView*)view;
                    chanumber.image=nil;
                    //  [phonenumber resignFirstResponder];
                }
            }
        }
            break;
        case 1:
            [self SelectImage:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 2:
            // 相机
            [self SelectImage: UIImagePickerControllerSourceTypeCamera];
            // sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 3:
            // 取消
            return;break;
    }

}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    GroupPhotoTableViewCell * tempcell=(GroupPhotoTableViewCell*)[self.tableview cellForRowAtIndexPath:indexPath];
    UIImageView *chanumber;
    for (UIView *view in tempcell.contentView.subviews) {
        if (view.tag==8) {
            chanumber =(UIImageView*)view;
            chanumber.image=image;
            img=image;
            //  [phonenumber resignFirstResponder];
        }
    }
    
    
}


- (void) SelectImage:(NSUInteger) type
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = (id)self;
    imagePickerController.allowsEditing = YES;
    
    if (type==UIImagePickerControllerSourceTypePhotoLibrary) {
        
        imagePickerController.sourceType = type;
       // isNeedexit=true;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
    }else{
      //  isNeedexit=true;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePickerController.sourceType = type;
            
            [self presentViewController:imagePickerController animated:YES completion:^{}];
            
        }
    }
    
}


#pragma mark-文本代理
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]){
        return YES;
    }
    
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (aString.length>25) {
        return NO;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    GroupSubTitleTableViewCell * tempcell=(GroupSubTitleTableViewCell*)[self.tableview cellForRowAtIndexPath:indexPath];
    UILabel *chanumber;
    for (UIView *view in tempcell.contentView.subviews) {
        if (view.tag==9) {
            chanumber =(UILabel*)view;
            chanumber.text=[NSString stringWithFormat:@"%lu",25l-aString.length];
            subject=aString;
          //  [phonenumber resignFirstResponder];
        }
    }

    return YES;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)GoNext:(UIBarButtonItem*)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    GroupSubTitleTableViewCell * tempcell=(GroupSubTitleTableViewCell*)[self.tableview cellForRowAtIndexPath:indexPath];
    UITextField *chanumber;
    for (UIView *view in tempcell.contentView.subviews) {
        if (view.tag==99) {
            chanumber =(UITextField*)view;
            subject=chanumber.text;
            break;
                       
        }
    }
    
    if (subject&&![subject isEqualToString:@""]) {
        GroupAddUserUIViewController *  adduser=[[GroupAddUserUIViewController alloc] init];
        adduser.image=img;
        adduser.subject=subject;
        [self.navigationController pushViewController:adduser animated:YES];
    }else{
    
        [Tool alert:NSLocalizedString(@"lbngvmsgsettitle", nil)];
    }
   


}

- (void)GoBack:(UIBarButtonItem*)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
