//
//  XunleiItemInfo.m
//  XunleiLixian-API
//
//  Created by Liu Chao on 6/10/12.
//  Copyright (c) 2012 HwaYing. All rights reserved.
//
/*This file is part of XunleiLixian-API.
 
 XunleiLixian-API is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "XunleiItemInfo.h"

@implementation XunleiItemInfo

NSString * const TaskStatusArray[]={
   @"waiting",@"downloading",@"complete",@"fail",@"pending"
};

- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSString *tmpStatus=[self _statusToString:self.status];
    [aCoder encodeObject:tmpStatus forKey:@"status"];
    [aCoder encodeObject:self.taskid forKey:@"taskid"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.size forKey:@"size"];
    [aCoder encodeObject:self.readableSize forKey:@"readableSize"];
    [aCoder encodeObject:self.downloadPercent forKey:@"loaddingProcess"];
    [aCoder encodeObject:self.retainDays forKey:@"retainDays"];
    [aCoder encodeObject:self.addDate forKey:@"addTime"];
    [aCoder encodeObject:self.downloadURL forKey:@"downloadURL"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.dcid forKey:@"dcid"];
    [aCoder encodeObject:self.originalURL forKey:@"originalurl"];
    [aCoder encodeObject:self.ifvod forKey:@"ifVod"];
    [aCoder encodeObject:self.isBT forKey:@"isBT"];
    
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if((self=[self init])){
        TaskStatus tmpStatus=[self _stringToTaskStatus:[aDecoder decodeObjectForKey:@"status"]];
        [self setStatus:tmpStatus];
        [self setTaskid:[aDecoder decodeObjectForKey:@"taskid"]];
        [self setName:[aDecoder decodeObjectForKey:@"name"]];
        [self setSize:[aDecoder decodeObjectForKey:@"size"]];
        [self setDownloadPercent:[aDecoder decodeObjectForKey:@"loaddingProcess"]];
        [self setRetainDays:[aDecoder decodeObjectForKey:@"retainDays"]];
        [self setAddDate:[aDecoder decodeObjectForKey:@"addTime"]];
        [self setDownloadURL:[aDecoder decodeObjectForKey:@"downloadURL"]];
        [self setType:[aDecoder decodeObjectForKey:@"type"]];
        [self setDcid:[aDecoder decodeObjectForKey:@"dcid"]];
        [self setOriginalURL:[aDecoder decodeObjectForKey:@"originalurl"]];
        [self setReadableSize:[aDecoder decodeObjectForKey:@"readableSize"]];
        [self setIfvod:[aDecoder decodeObjectForKey:@"ifVod"]];
        [self setIsBT:[aDecoder decodeObjectForKey:@"isBT"]];
        
    }
    return self;
}

-(NSString *) _statusToString:(TaskStatus) status{
    return TaskStatusArray[status];
}
-(TaskStatus) _stringToTaskStatus:(NSString*) taskStatusString{
    int r;
    for(int i=0;i<sizeof(TaskStatusArray)-1;i++){
        if([(NSString*)TaskStatusArray[i] isEqualToString:taskStatusString]){
            r=i;
            break;
        }
    }
    return (TaskStatus)r;
}


@end
