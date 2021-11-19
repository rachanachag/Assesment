
/****** Object:  Table [dbo].[Coupons]    Script Date: 19/11/2021 10:42:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Coupons](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OfferId] [smallint] NOT NULL,
	[Title] [varchar](255) NULL,
	[Code] [varchar](10) NULL,
	[Description] [varchar](max) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[DiscountAmount] [float] NULL,
	[MaximumCouponUse] [int] NULL,
	[MaximumCouponUsePerUser] [int] NULL,
 CONSTRAINT [PK_Coupons_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_Coupons_Code] UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CouponUserMapping]    Script Date: 19/11/2021 10:42:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CouponUserMapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CouponId] [int] NULL,
	[UserId] [int] NULL,
	[RedemptionDate] [datetime] NULL,
	[RedemptionCode] [varchar](10) NULL,
 CONSTRAINT [PK_CouponUserMapping_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Offers]    Script Date: 19/11/2021 10:42:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Offers](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
 CONSTRAINT [PK_Offers_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 19/11/2021 10:42:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](300) NOT NULL,
	[FirstName] [varchar](300) NULL,
	[Surname] [varchar](300) NULL,
	[EmailId] [varchar](255) NULL,
	[Mobile] [varchar](15) NULL,
	[Password] [varbinary](max) NULL,
	[Salt] [varbinary](max) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Users_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Coupons]  WITH NOCHECK ADD  CONSTRAINT [Fk_Coupons_OfferId] FOREIGN KEY([OfferId])
REFERENCES [dbo].[Offers] ([Id])
GO
ALTER TABLE [dbo].[Coupons] CHECK CONSTRAINT [Fk_Coupons_OfferId]
GO
ALTER TABLE [dbo].[CouponUserMapping]  WITH NOCHECK ADD  CONSTRAINT [Fk_CouponUserMapping_CouponId] FOREIGN KEY([CouponId])
REFERENCES [dbo].[Coupons] ([Id])
GO
ALTER TABLE [dbo].[CouponUserMapping] CHECK CONSTRAINT [Fk_CouponUserMapping_CouponId]
GO
ALTER TABLE [dbo].[CouponUserMapping]  WITH NOCHECK ADD  CONSTRAINT [Fk_CouponUserMapping_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[CouponUserMapping] CHECK CONSTRAINT [Fk_CouponUserMapping_UserId]
GO
/****** Object:  StoredProcedure [dbo].[spCheckCouponRedemptions]    Script Date: 19/11/2021 10:42:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[spCheckCouponRedemptions]
(
	@CouponId Int,
	@UserId Int 
)
AS

SET NOCOUNT ON

Declare @MaximumCouponUsePerUser Int,@MaximumCouponUse Int,@CanCouponRedeem Bit = 0

If Exists (Select 1 From [dbo].[Coupons] Where Id = @CouponId and Getdate() between StartDate and EndDate)
Begin
	Select 
	@MaximumCouponUsePerUser = MaximumCouponUsePerUser,
	@MaximumCouponUse = MaximumCouponUse
	From [dbo].[Coupons] Where Id = @CouponId and Getdate() between StartDate and EndDate

	If 
	(Select Count(*) from [dbo].[CouponUserMapping] With(Nolock) Where UserId = @UserId and CouponId = @CouponId) < @MaximumCouponUsePerUser
	and
	(Select Count(*) from [dbo].[CouponUserMapping] With(Nolock) Where CouponId = @CouponId) < @MaximumCouponUse
	Begin
		Select 1 CanCouponRedeem
	End
	Else 
		Select 0 CanCouponRedeem
End
GO
/****** Object:  StoredProcedure [dbo].[spGetActiveCouponList]    Script Date: 19/11/2021 10:42:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[spGetActiveCouponList]
AS
SET NOCount ON
Select O.[Name] as OfferName,
Title,
Code,
Description,
StartDate,
EndDate,
DiscountAmount,
MaximumCouponUse,
MaximumCouponUsePerUser
From [dbo].[Coupons] C
Inner Join [dbo].[Offers] O On O.Id = C.OfferId
Where GETDATE() between C.StartDate and c.EndDate


GO
/****** Object:  StoredProcedure [dbo].[spGetRedemptionCount]    Script Date: 19/11/2021 10:42:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec spGetRedemptionCount '2021-11-17','2021-11-18'
CREATE Proc [dbo].[spGetRedemptionCount]
@StartDate Date,
@EndDate Date
AS
Begin
SET NoCount ON
Select C.Title CouponName,O.Name OfferName,U.UserName ,RedemptionDate ,count(CUM.ID)RedemptionCount 
from [dbo].[Coupons] C
Inner Join [dbo].[Offers] O on C.Id = C.OfferId
Inner Join [dbo].[CouponUserMapping] CUM on CUM.CouponId = C.Id
Inner Join [dbo].[Users] U on U.Id = UserId
Where RedemptionDate between @StartDate and @EndDate
Group by C.Title,O.Name,RedemptionDate,U.UserName
End
GO
