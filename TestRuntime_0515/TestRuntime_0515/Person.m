//
//  Person.m
//  TestRuntime_0515
//
//  Created by dhp on 17/5/15.
//  Copyright © 2017年 dhp. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>
#import "Animal.h"

@implementation Person

void eat(id self,SEL _cmd)
{
    NSLog(@"Person eat");
}

//resolvedInstanceMethod: 适合给类/对象动态添加一个相应的实现
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(eat)) {
        //添加方法实现
        class_addMethod(self, sel, (IMP)eat, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

//forwardingTargetForSelector：适合将消息转发给其他对象处理
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return [[Animal alloc] init];
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *sel = NSStringFromSelector(aSelector);
    if ([sel isEqualToString:@"eat"]) {
        //为转发方法手动生成方法签名
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
        //关于生成签名的类型"v@:"每一个方法会默认隐藏两个参数self、_cmd，self代表方法调用者，_cmd代表这个方法的SEL，签名类型就是用来描述这个方法的返回值、参数的，v代表返回值为void，@表示self，:表示_cmd。
    }
    return [super methodSignatureForSelector:aSelector];
}

-(void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL selector = [anInvocation selector];
    //新建需要转发消息的对象
    Animal *animal = [[Animal alloc] init];
    if ([animal respondsToSelector:selector]) {
        //唤醒该方法
        [anInvocation invokeWithTarget:animal];
    }
}
@end
