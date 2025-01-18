import { JSON } from "@kit.ArkTS";

@Observed
export class MoneyModel {
  num: string;
  isCheck: string;

  constructor(num: string, isCheck: string) {
    this.num = num;
    this.isCheck = isCheck;
  }
}

@Observed
export class MoneyListModel {
  moneyList: Array<MoneyModel>;

  constructor(moneyList: Array<MoneyModel>) {
    this.moneyList = moneyList;
  }

  toggleSelection(index: number) {
    this.moneyList = this.moneyList.map((item, i) => {
      return new MoneyModel(item.num, i === index ? "1" : "0");
    });

    console.log("更新后集合===>", JSON.stringify(this.moneyList));
  }
}